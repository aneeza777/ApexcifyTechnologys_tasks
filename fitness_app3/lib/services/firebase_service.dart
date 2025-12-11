import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';
import '../models/bmi_entry.dart';
import '../models/step_entry.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Workout to Firebase
  Future<void> addWorkout(Workout workout) async {
    await _firestore.collection('workouts').add({
      'name': workout.name,
      'calories': workout.calories,
      'minutes': workout.minutes,
      'date': workout.date.toIso8601String(),
    });
  }

  // Add BMIEntry to Firebase
  Future<void> addBMIEntry(BMIEntry entry) async {
    await _firestore.collection('bmi_entries').add({
      'value': entry.value,
      'date': entry.date.toIso8601String(),
    });
  }

  // Add StepEntry to Firebase
  Future<void> addStepEntry(StepEntry entry) async {
    await _firestore.collection('steps').add({
      'count': entry.count,
      'date': entry.date.toIso8601String(),
    });
  }

  // Fetch Workouts
  Stream<List<Workout>> fetchWorkouts() {
    return _firestore.collection('workouts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Workout(
          name: doc['name'],
          calories: doc['calories'],
          minutes: doc['minutes'],
          date: DateTime.parse(doc['date']),
        )).toList());
  }

  // Fetch BMI Entries
  Stream<List<BMIEntry>> fetchBMIEntries() {
    return _firestore.collection('bmi_entries').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BMIEntry(
          value: doc['value'],
          date: DateTime.parse(doc['date']),
        )).toList());
  }

  // Fetch Step Entries
  Stream<List<StepEntry>> fetchStepEntries() {
    return _firestore.collection('steps').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => StepEntry(
          count: doc['count'],
          date: DateTime.parse(doc['date']),
        )).toList());
  }
}
