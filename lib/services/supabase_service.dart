import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/worker.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class SupabaseService {
  // Fetch attendance records for a worker
  Future<List<Map<String, dynamic>>> fetchAttendance(String workerId) async {
    final response = await supabase
        .from('attendance_records')
        .select()
        .eq('worker_id', workerId);
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch payment records for a worker
  Future<List<Map<String, dynamic>>> fetchPayments(String workerId) async {
    final response = await supabase
        .from('payment_records')
        .select()
        .eq('worker_id', workerId);
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch advance records for a worker
  Future<List<Map<String, dynamic>>> fetchAdvances(String workerId) async {
    final response = await supabase
        .from('advance_records')
        .select()
        .eq('worker_id', workerId);
    return List<Map<String, dynamic>>.from(response);
  }

  final supabase = Supabase.instance.client;

  // Workers
  Future<List<Map<String, dynamic>>> fetchWorkers() async {
    final response = await supabase.from('workers').select();
    return List<Map<String, dynamic>>.from(response);
    return [];
  }

  Future<void> addWorker(Worker worker) async {
    await supabase.from('workers').insert({
      'name': worker.name,
      'daily_wage': worker.dailyWage,
    });
  }

  Future<void> updateWorker(String id, Worker worker) async {
    await supabase.from('workers').update({
      'name': worker.name,
      'daily_wage': worker.dailyWage,
    }).eq('id', id);
  }

  Future<void> deleteWorker(String id) async {
    await supabase.from('workers').delete().eq('id', id);
  }

  // Attendance
  Future<void> addAttendance(String workerId, AttendanceRecord record) async {
    await supabase.from('attendance_records').insert({
      'worker_id': workerId,
      'date': record.date.toIso8601String(),
      'type': record.type.name,
    });
  }

  // Payments
  Future<void> addPayment(String workerId, PaymentRecord record) async {
    await supabase.from('payment_records').insert({
      'worker_id': workerId,
      'date': record.date.toIso8601String(),
      'amount_paid': record.amountPaid,
      'via_advance': record.viaAdvance,
      'remaining': record.remaining,
    });
  }

  // Advances
  Future<void> addAdvance(String workerId, AdvanceRecord record) async {
    await supabase.from('advance_records').insert({
      'worker_id': workerId,
      'date': record.date.toIso8601String(),
      'amount': record.amount,
    });
  }
}
