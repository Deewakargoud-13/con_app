import 'package:hive/hive.dart';
part 'payment.g.dart';

@HiveType(typeId: 3)
class PaymentRecord extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  double amountPaid;
  @HiveField(2)
  bool viaAdvance;
  @HiveField(3)
  double remaining;

  PaymentRecord({
    required this.date,
    required this.amountPaid,
    required this.viaAdvance,
    required this.remaining,
  });

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      date: DateTime.parse(map['date']),
      amountPaid: (map['amount_paid'] ?? 0).toDouble(),
      viaAdvance: map['via_advance'] ?? false,
      remaining: (map['remaining'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amount_paid': amountPaid,
      'via_advance': viaAdvance,
      'remaining': remaining,
    };
  }
}
