import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/worker.dart';
import '../models/attendance.dart';
import '../widgets/app_drawer.dart';
import '../navigation/route_observer.dart';

double calculateFinalPending(List<AttendanceRecord> attendance,
    List<AdvanceRecord> advances, double dailyWage, DateTime month) {
  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
  List<MapEntry<DateTime, double>> pendingQueue = [];
  double carryForward = 0.0;
  for (int i = 1; i <= daysInMonth; i++) {
    final date = DateTime(month.year, month.month, i);
    final att = attendance.firstWhere(
      (a) =>
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day,
      orElse: () => AttendanceRecord(date: date, type: AttendanceType.absent),
    );
    final wage = dailyWage *
        (att.type == AttendanceType.full
            ? 1.0
            : att.type == AttendanceType.half
                ? 0.5
                : att.type == AttendanceType.oneAndHalf
                    ? 1.5
                    : 0.0);
    if (wage > 0) {
      pendingQueue.add(MapEntry(date, wage));
    }
    final adv = advances.firstWhere(
      (a) =>
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day,
      orElse: () => AdvanceRecord(date: date, amount: 0),
    );
    double availableAdvance = adv.amount + carryForward;
    int j = 0;
    while (availableAdvance > 0 && j < pendingQueue.length) {
      final entry = pendingQueue[j];
      final toClear = entry.value;
      if (availableAdvance >= toClear) {
        availableAdvance -= toClear;
        pendingQueue[j] = MapEntry(entry.key, 0.0);
      } else {
        pendingQueue[j] = MapEntry(entry.key, toClear - availableAdvance);
        availableAdvance = 0.0;
      }
      j++;
    }
    pendingQueue.removeWhere((entry) => entry.value == 0.0);
    carryForward = availableAdvance;
  }
  return pendingQueue.fold(0.0, (sum, entry) => sum + entry.value);
}

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen>
    with RouteAware {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Trigger an initial refresh after first frame so context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh(context);
    });
  }

  Future<void> _refresh(BuildContext context) async {
    setState(() => _loading = true);
    try {
      await Provider.of<WorkerListModel>(context, listen: false)
          .loadFromSupabase();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    // Screen was pushed, ensure fresh data
    _refresh(context);
  }

  @override
  void didPopNext() {
    // Returned back to this screen, refresh
    _refresh(context);
  }

  @override
  void dispose() {
    // Unsubscribe from route observer
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerList = Provider.of<WorkerListModel>(context);

    double totalAllPending = 0;

    List<Map<String, dynamic>> reportRows = workerList.workers.map((worker) {
      double totalWage = 0;
      double totalAdvance = 0;
      int presentDays = 0;
      List<MapEntry<DateTime, double>> pendingQueue = [];
      double carryForward = 0.0;
      final today = DateTime.now();
      final currentMonth = today.month;
      final currentYear = today.year;
      final daysInMonth = DateUtils.getDaysInMonth(currentYear, currentMonth);
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(currentYear, currentMonth, i);
        final attendance = worker.attendance.firstWhere(
          (a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day,
          orElse: () =>
              AttendanceRecord(date: date, type: AttendanceType.absent),
        );
        if (attendance.type != AttendanceType.absent) presentDays++;
        final wageForDay = worker.dailyWage *
            (attendance.type == AttendanceType.full
                ? 1.0
                : attendance.type == AttendanceType.half
                    ? 0.5
                    : attendance.type == AttendanceType.oneAndHalf
                        ? 1.5
                        : 0.0);
        final advanceRecord = worker.advances.firstWhere(
          (a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day,
          orElse: () => AdvanceRecord(date: date, amount: 0),
        );
        double availableAdvance = advanceRecord.amount + carryForward;
        // 1. Add today's pending to the queue
        if (wageForDay > 0) {
          pendingQueue.add(MapEntry(date, wageForDay));
        }
        // 2. Use available advance to clear oldest pending first
        int j = 0;
        while (availableAdvance > 0 && j < pendingQueue.length) {
          final entry = pendingQueue[j];
          final toClear = entry.value;
          if (availableAdvance >= toClear) {
            availableAdvance -= toClear;
            pendingQueue[j] = MapEntry(entry.key, 0.0);
          } else {
            pendingQueue[j] = MapEntry(entry.key, toClear - availableAdvance);
            availableAdvance = 0.0;
          }
          j++;
        }
        // 3. Remove fully paid days from the queue
        pendingQueue.removeWhere((entry) => entry.value == 0.0);
        // 4. Carry forward any leftover advance
        carryForward = availableAdvance;
        totalWage += wageForDay;
        totalAdvance += advanceRecord.amount;
        // 4. Carry forward any leftover advance
        carryForward = availableAdvance;
      }
      double totalPending = calculateFinalPending(
          worker.attendance,
          worker.advances,
          worker.dailyWage,
          DateTime(currentYear, currentMonth));
      return {
        'name': worker.name,
        'presentDays': presentDays,
        'totalWage': totalWage,
        'totalAdvance': totalAdvance,
        'pending': totalPending,
        'remainingAdvance': 0.0, // Not used in summary
      };
    }).toList();

    // Correctly sum all workers' pending values for the month
    totalAllPending =
        reportRows.fold(0.0, (sum, row) => sum + (row['pending'] as double));

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Monthly Report'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : () => _refresh(context),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_loading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Refreshing...'),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: reportRows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final row = reportRows[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  color: Colors.blue.shade700, size: 28),
                              const SizedBox(width: 10),
                              Text(row['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue.shade700)),
                              const Spacer(),
                              Icon(Icons.calendar_today_outlined,
                                  size: 18, color: Colors.blueGrey.shade300),
                              const SizedBox(width: 4),
                              Text('${row['presentDays']} days',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey.shade400)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  color: Colors.green.shade400, size: 20),
                              const SizedBox(width: 4),
                              Text('Wage: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey.shade600)),
                              Text('₹${row['totalWage'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700)),
                              const SizedBox(width: 18),
                              Icon(Icons.account_balance_wallet_outlined,
                                  color: Colors.orange.shade400, size: 20),
                              const SizedBox(width: 4),
                              Text('Advance: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey.shade600)),
                              Text('₹${row['totalAdvance'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.pending_actions,
                                  color: Colors.orange.shade300, size: 20),
                              const SizedBox(width: 4),
                              Text('Pending: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey.shade600)),
                              Text('₹${row['pending'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          (row['totalAdvance'] > row['totalWage'])
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                      'Advance Balance: ₹${(row['totalAdvance'] - row['totalWage']).toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold)),
                                )
                              : row['pending'] == 0
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Clear',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                          'Pending ₹${row['pending'].toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.bold)),
                                    ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: totalAllPending == 0
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: totalAllPending == 0
                      ? const Text('All Clear',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20))
                      : Text(
                          'Total Pending: ₹${totalAllPending.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
