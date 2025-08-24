import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/worker.dart';
import 'worker_dashboard_screen.dart';
import 'monthly_report_screen.dart';

class WorkerListScreen extends StatelessWidget {
  const WorkerListScreen({Key? key}) : super(key: key);

  void _showAddWorkerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final wageController = TextEditingController();
    // final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
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
                    'Add Worker',
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
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

  void _showEditWorkerDialog(
      BuildContext context, Worker worker, WorkerListModel workerList) {
    final nameController = TextEditingController(text: worker.name);
    final wageController =
        TextEditingController(text: worker.dailyWage.toStringAsFixed(2));
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Worker'),
          content: SizedBox(
            width: screenWidth * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Worker Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: wageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Wage'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
                      workerList.workers.indexOf(worker), updatedWorker);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerList = Provider.of<WorkerListModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 32.0 : 16.0;
    // No loading indicator needed: workers is always a non-null list
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey[100],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.account_circle,
                        size: 40, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contractor App',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Welcome!',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.people_outline, color: Colors.blue.shade700),
              title: const Text('Workers',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.bar_chart_rounded, color: Colors.orange.shade700),
              title: const Text('Monthly Report',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MonthlyReportScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Workers'),
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
      backgroundColor: Colors.grey[100],
      body: (workerList.workers.isEmpty)
          ? Center(
              child: SizedBox(
                width: screenWidth * 0.7,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 26),
                  label: const Text('Add Worker',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: () => _showAddWorkerDialog(context),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                        vertical: padding, horizontal: padding),
                    itemCount: workerList.workers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final worker = workerList.workers[index];
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
                        child: Row(
                          children: [
                            Icon(Icons.person_outline,
                                color: Colors.blue.shade700, size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(worker.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue.shade700)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '₹${worker.dailyWage.toStringAsFixed(2)} per day',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey.shade400)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: Colors.orange.shade700),
                              onPressed: () => _showEditWorkerDialog(
                                  context, worker, workerList),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red.shade400),
                              onPressed: () async {
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
                              tooltip: 'Delete',
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.blueGrey.shade200, size: 20),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkerDashboardScreen(worker: worker),
                                  ),
                                );
                              },
                              tooltip: 'View',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: SizedBox(
                    width: screenWidth * 0.7,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 26),
                      label: const Text('Add Worker',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () => _showAddWorkerDialog(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
