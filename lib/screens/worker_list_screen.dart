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
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Worker'),
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
                if (nameController.text.isNotEmpty && wageController.text.isNotEmpty) {
                  Provider.of<WorkerListModel>(context, listen: false).addWorker(
                    Worker(
                      name: nameController.text,
                      dailyWage: double.tryParse(wageController.text) ?? 0.0,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditWorkerDialog(BuildContext context, Worker worker, WorkerListModel workerList) {
    final nameController = TextEditingController(text: worker.name);
    final wageController = TextEditingController(text: worker.dailyWage.toStringAsFixed(2));
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
                if (nameController.text.isNotEmpty && wageController.text.isNotEmpty) {
                  worker.name = nameController.text;
                  worker.dailyWage = double.tryParse(wageController.text) ?? worker.dailyWage;
                  workerList.updateWorker();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final buttonFontSize = isTablet ? 22.0 : 16.0;
    final tileFontSize = isTablet ? 22.0 : 16.0;
    final padding = isTablet ? 32.0 : 16.0;
    final cardColor = Colors.blue.shade50;
    final tileColor = Colors.blue.shade50;
    return Scaffold(
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
      backgroundColor: Colors.white,
      body: workerList.workers.isEmpty
          ? Center(
              child: SizedBox(
                width: screenWidth * 0.7,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text('Add Worker', style: TextStyle(fontSize: buttonFontSize)),
                  onPressed: () => _showAddWorkerDialog(context),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
                    itemCount: workerList.workers.length,
                    itemBuilder: (context, index) {
                      final worker = workerList.workers[index];
                      return Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: isTablet ? 32 : 0),
                        child: ListTile(
                          tileColor: tileColor,
                          title: Text(worker.name, style: TextStyle(fontSize: tileFontSize)),
                          subtitle: Text('₹${worker.dailyWage.toStringAsFixed(2)} per day', style: TextStyle(fontSize: tileFontSize * 0.85)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkerDashboardScreen(worker: worker),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditWorkerDialog(context, worker, workerList),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Worker'),
                                      content: const Text('Are you sure you want to delete this worker? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
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
                            ],
                          ),
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
                      icon: const Icon(Icons.add),
                      label: Text('Add Worker', style: TextStyle(fontSize: buttonFontSize)),
                      onPressed: () => _showAddWorkerDialog(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 