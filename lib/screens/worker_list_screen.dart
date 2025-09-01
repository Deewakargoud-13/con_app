import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../models/worker.dart';
import 'worker_dashboard_screen.dart';
import 'monthly_report_screen.dart';

class WorkerListScreen extends StatelessWidget {
  void _showEditWorkerDialog(
      BuildContext context, Worker worker, WorkerListModel workerList) {
    final nameController = TextEditingController(text: worker.name);
    final wageController =
        TextEditingController(text: worker.dailyWage.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Edit Worker',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Worker Name',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: wageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money_outlined),
                    hintText: 'Daily Wage',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty &&
                              wageController.text.isNotEmpty) {
                            final updatedWorker = Worker(
                              name: nameController.text,
                              dailyWage: double.tryParse(wageController.text) ??
                                  worker.dailyWage,
                              id: worker.id,
                            );
                            workerList.updateWorker(
                                workerList.workers.indexOf(worker),
                                updatedWorker);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  const WorkerListScreen({Key? key}) : super(key: key);

  void _showAddWorkerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final wageController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade100,
                        ),
                        child: const Icon(Icons.person_add_alt_1,
                            color: Colors.blue, size: 32),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Add Worker',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Worker Name',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: wageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee_rounded,
                        color: Colors.green),
                    hintText: 'Daily Wage',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty &&
                              wageController.text.isNotEmpty) {
                            Provider.of<WorkerListModel>(context, listen: false)
                                .addWorker(
                              Worker(
                                name: nameController.text,
                                dailyWage:
                                    double.tryParse(wageController.text) ?? 0.0,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 2,
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerList = Provider.of<WorkerListModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 32.0 : 16.0;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Workers',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Monthly Report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          if (workerList.workers.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.blue.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.group, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'No workers yet',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first worker.',
                    style: TextStyle(
                        fontSize: 16, color: Colors.blueGrey.shade400),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              padding:
                  EdgeInsets.symmetric(vertical: padding, horizontal: padding),
              itemCount: workerList.workers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final worker = workerList.workers[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.85),
                        Colors.blue.shade50.withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                        color: Colors.blue.shade100.withOpacity(0.3)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          worker.name.isNotEmpty
                              ? worker.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                    color: Colors.blue.shade700)),
                            const SizedBox(height: 4),
                            Text(
                              '₹${worker.dailyWage.toStringAsFixed(2)} per day',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueGrey.shade400),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Edit',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _showEditWorkerDialog(
                                context, worker, workerList),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(Icons.edit,
                                  color: Colors.orange.shade700, size: 24),
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Delete',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Worker'),
                                  content: const Text(
                                      'Are you sure you want to delete this worker? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                workerList.removeWorker(index);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(Icons.delete_outline,
                                  color: Colors.red.shade400, size: 24),
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'View',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.black.withOpacity(0.08),
                                builder: (context) => Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.blueGrey.withOpacity(0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue.shade700),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Loading worker...',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WorkerDashboardScreen(worker: worker),
                                ),
                              );
                              if (Navigator.canPop(context)) {
                                Navigator.pop(
                                    context); // Dismiss progress dialog
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.blueGrey.shade200, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          // Floating Add Worker Button
          Positioned(
            bottom: 32,
            right: 32,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddWorkerDialog(context),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, size: 26),
              label: const Text('Add Worker',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
