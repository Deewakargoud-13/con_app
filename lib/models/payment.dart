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
} 