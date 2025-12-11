import 'package:hive/hive.dart';

part 'step_entry.g.dart';

@HiveType(typeId: 2)
class StepEntry extends HiveObject {
  @HiveField(0)
  int count;

  @HiveField(1)
  DateTime date;

  StepEntry({
    required this.count,
    required this.date,
  });
}
