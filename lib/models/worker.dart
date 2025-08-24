import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import '../services/supabase_service.dart';
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

  factory AdvanceRecord.fromMap(Map<String, dynamic> map) {
    return AdvanceRecord(
      date: DateTime.parse(map['date']),
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }
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
  String? id; // Supabase id

  Worker({
    required this.name,
    required this.dailyWage,
    this.advance = 0.0,
    List<AttendanceRecord>? attendance,
    List<PaymentRecord>? payments,
    List<AdvanceRecord>? advances,
    this.id,
  })  : attendance = attendance ?? [],
        payments = payments ?? [],
        advances = advances ?? [];

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] as String?,
      name: map['name'] ?? '',
      dailyWage: (map['daily_wage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'daily_wage': dailyWage,
    };
  }
}

class WorkerListModel extends ChangeNotifier {
  final List<Worker> _workers = [];
  final SupabaseService _supabaseService = SupabaseService();

  List<Worker> get workers => _workers;

  Future<void> loadFromSupabase() async {
    final data = await _supabaseService.fetchWorkers();
    _workers.clear();
    for (var item in data) {
      _workers.add(Worker.fromMap(item));
    }
    notifyListeners();
  }

  Future<void> addWorker(Worker worker) async {
    await _supabaseService.addWorker(worker);
    await loadFromSupabase();
  }

  Future<void> removeWorker(int index) async {
    final worker = _workers[index];
    if (worker.id != null) {
      await _supabaseService.deleteWorker(worker.id!);
    }
    await loadFromSupabase();
  }

  Future<void> updateWorker(int index, Worker worker) async {
    final oldWorker = _workers[index];
    if (oldWorker.id != null) {
      await _supabaseService.updateWorker(oldWorker.id!, worker);
    }
    await loadFromSupabase();
  }
}
