import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'attendance.dart';
import 'payment.dart';
part 'worker.g.dart';

@HiveType(typeId: 5)
class AdvanceRecord extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  double amount;

  AdvanceRecord({required this.date, required this.amount});
}

@HiveType(typeId: 4)
class Worker extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double dailyWage;
  @HiveField(2)
  double advance; // Deprecated: use advances list instead
  @HiveField(3)
  List<AttendanceRecord> attendance;
  @HiveField(4)
  List<PaymentRecord> payments;
  @HiveField(5)
  List<AdvanceRecord> advances;

  Worker({
    required this.name,
    required this.dailyWage,
    this.advance = 0.0,
    List<AttendanceRecord>? attendance,
    List<PaymentRecord>? payments,
    List<AdvanceRecord>? advances,
  })  : attendance = attendance ?? [],
        payments = payments ?? [],
        advances = advances ?? [];
}

class WorkerListModel extends ChangeNotifier {
  final List<Worker> _workers = [];

  List<Worker> get workers => _workers;

  Future<void> loadFromHive() async {
    final box = await Hive.openBox<Worker>('workers');
    _workers.clear();
    _workers.addAll(box.values);
    notifyListeners();
  }

  Future<void> saveToHive() async {
    final box = await Hive.openBox<Worker>('workers');
    await box.clear();
    for (var worker in _workers) {
      await box.add(worker);
    }
  }

  void addWorker(Worker worker) {
    _workers.add(worker);
    saveToHive();
    notifyListeners();
  }

  void removeWorker(int index) {
    _workers.removeAt(index);
    saveToHive();
    notifyListeners();
  }

  void updateWorker() {
    saveToHive();
    notifyListeners();
  }
} 