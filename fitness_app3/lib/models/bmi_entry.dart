import 'package:hive/hive.dart';

part 'bmi_entry.g.dart';

@HiveType(typeId: 1)
class BMIEntry extends HiveObject {
  @HiveField(0)
  double value;

  @HiveField(1)
  DateTime date;

  BMIEntry({required this.value, required this.date});
}
