import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/bmi_entry.dart';
import '../models/step_entry.dart';
import '../models/workout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Box<BMIEntry> get bmiBox => Hive.box<BMIEntry>('bmi_entries');
  Box<StepEntry> get stepBox => Hive.box<StepEntry>('steps');
  Box<Workout> get workoutBox => Hive.box<Workout>('workouts');

  String bmiSuggestion(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String bmiTips(double bmi) {
    if (bmi < 18.5) return 'Eat more calories and protein.';
    if (bmi < 25) return 'Maintain your healthy lifestyle.';
    if (bmi < 30) return 'Exercise regularly and watch diet.';
    return 'Consult a doctor for a proper plan.';
  }

  List<FlSpot> buildWeeklyStepsData() {
    final last7 = stepBox.values.toList().reversed.take(7).toList();
    return List.generate(last7.length, (i) => FlSpot(i.toDouble(), last7[i].count.toDouble()));
  }

  List<FlSpot> buildWeeklyWorkoutsData() {
    final last7 = workoutBox.values.toList().reversed.take(7).toList();
    return List.generate(last7.length, (i) => FlSpot(i.toDouble(), last7[i].calories.toDouble()));
  }

  List<FlSpot> buildWeeklyBMIData() {
    final last7 = bmiBox.values.toList().reversed.take(7).toList();
    return List.generate(last7.length, (i) => FlSpot(i.toDouble(), last7[i].value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                statsCard(
                  'Steps Today',
                  stepBox.values.fold<int>(0, (prev, e) => prev + e.count),
                  Icons.directions_walk,
                  Colors.blue,
                ),
                statsCard(
                  'Workouts Today',
                  workoutBox.values.fold<int>(0, (prev, e) => prev + e.calories),
                  Icons.fitness_center,
                  Colors.red,
                ),
                statsCard(
                  'Latest BMI',
                  bmiBox.values.isEmpty ? 0 : bmiBox.values.last.value.toInt(),
                  Icons.monitor_weight,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Charts
            const Text('Weekly Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: stepsChart(),
            ),
            const SizedBox(height: 20),
            const Text('Weekly Workouts (Calories)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: workoutsChart(),
            ),
            const SizedBox(height: 20),
            const Text('Weekly BMI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: bmiChart(),
            ),
            const SizedBox(height: 20),

            // BMI Suggestions
            Card(
              color: Colors.yellow[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: bmiBox.values.isEmpty
                    ? const Text('No BMI data yet.')
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BMI Suggestion: ${bmiSuggestion(bmiBox.values.last.value)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Tips: ${bmiTips(bmiBox.values.last.value)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card statsCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget stepsChart() {
    final spots = buildWeeklyStepsData();
    final maxY = spots.isEmpty ? 100.0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 50;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 10)),
            ),
          ),
        ),
      ),
    );
  }

  Widget workoutsChart() {
    final spots = buildWeeklyWorkoutsData();
    final maxY = spots.isEmpty ? 100.0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 50;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.red,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 10)),
            ),
          ),
        ),
      ),
    );
  }

  Widget bmiChart() {
    final spots = buildWeeklyBMIData();
    final maxY = spots.isEmpty ? 40.0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10;
    return LineChart(
      LineChartData(
        minY: 10,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.green,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 10)),
            ),
          ),
        ),
      ),
    );
  }
}
