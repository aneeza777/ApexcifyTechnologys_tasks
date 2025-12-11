import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 0)
class Workout extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int calories;

  @HiveField(2)
  int minutes;

  @HiveField(3)
  DateTime date;

  Workout({
    required this.name,
    required this.calories,
    required this.minutes,
    required this.date,
  });
}
