import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/workout.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _minutesController = TextEditingController();

  void _addWorkout() {
    final name = _nameController.text.trim();
    final calories = int.tryParse(_caloriesController.text);
    final minutes = int.tryParse(_minutesController.text);

    if (name.isEmpty || calories == null || minutes == null) return;

    final box = Hive.box<Workout>('workouts');
    box.add(Workout(
      name: name,
      calories: calories,
      minutes: minutes,
      date: DateTime.now(),
    ));

    _nameController.clear();
    _caloriesController.clear();
    _minutesController.clear();
  }

  void _deleteWorkout(int index) {
    final box = Hive.box<Workout>('workouts');
    box.getAt(index)?.delete();
  }

  Map<String, int> _weeklyCalories(Box<Workout> box) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: i)));
    Map<String, int> data = {};
    for (var day in last7Days) {
      final total = box.values
          .where((w) => w.date.year == day.year && w.date.month == day.month && w.date.day == day.day)
          .fold<int>(0, (prev, w) => prev + w.calories);
      data["${day.month}/${day.day}"] = total;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Workout>('workouts');

    return Scaffold(
      appBar: AppBar(title: const Text("Workouts Tracker")),
      body: Column(
        children: [
          // Add new workout
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Workout Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _addWorkout, child: const Text('Add')),
                  ],
                ),
              ],
            ),
          ),

          // Workout list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Workout> box, _) {
                final workouts = box.values.toList().reversed.toList();

                if (workouts.isEmpty) {
                  return const Center(child: Text("No workouts yet."));
                }

                return ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (_, index) {
                    final w = workouts[index];
                    return ListTile(
                      title: Text(w.name),
                      subtitle: Text("${w.calories} cal • ${w.minutes} min"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkout(box.length - 1 - index),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Weekly calories chart
          SizedBox(
            height: 200,
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Workout> box, _) {
                final weeklyData = _weeklyCalories(box);
               // final maxY = (weeklyData.values.isEmpty) ? 100.0 : weeklyData.values.reduce((a, b) => a > b ? a.toDouble() : b.toDouble()) + 50;
                final maxY = (weeklyData.values.isEmpty)
                    ? 100.0
                    : weeklyData.values.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b) + 50;

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barGroups: weeklyData.entries.map((entry) {
                        return BarChartGroupData(
                          x: int.parse(entry.key.split('/')[1]),
                          barRods: [BarChartRodData(toY: entry.value.toDouble(), color: Colors.deepPurple)],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final day = weeklyData.keys.firstWhere(
                                      (k) => int.parse(k.split('/')[1]) == val.toInt(),
                                  orElse: () => '');
                              return Text(day.split('/')[1]);
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
