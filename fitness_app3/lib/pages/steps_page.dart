import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/step_entry.dart';

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  final _stepsController = TextEditingController();

  void _addSteps({int? count}) {
    final stepCount = count ?? int.tryParse(_stepsController.text);
    if (stepCount == null) return;
    final box = Hive.box<StepEntry>('steps');
    box.add(StepEntry(count: stepCount, date: DateTime.now()));
    _stepsController.clear();
  }

  void _deleteSteps(int index) {
    final box = Hive.box<StepEntry>('steps');
    box.getAt(index)?.delete();
  }

  void _editSteps(int index) {
    final box = Hive.box<StepEntry>('steps');
    final entry = box.getAt(index);
    if (entry == null) return;

    _stepsController.text = entry.count.toString();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Steps'),
        content: TextField(
          controller: _stepsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Steps Count'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newValue = int.tryParse(_stepsController.text);
              if (newValue != null) {
                entry.count = newValue;
                entry.save();
                _stepsController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              _stepsController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<StepEntry>('steps');

    return Scaffold(
      appBar: AppBar(title: const Text("Steps Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter steps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addSteps(),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<StepEntry> box, _) {
                  final entries = box.values.toList();
                  if (entries.isEmpty) {
                    return const Center(child: Text("No steps recorded yet."));
                  }

                  // Weekly chart data
                  final weeklyData = <String, int>{};
                  for (var e in entries) {
                    final day = "${e.date.month}/${e.date.day}";
                    weeklyData[day] = e.count;
                  }

                  final spots = weeklyData.entries
                      .map((e) => FlSpot(
                      weeklyData.keys.toList().indexOf(e.key).toDouble(),
                      e.value.toDouble()))
                      .toList();

             //     final maxY = (weeklyData.values.isEmpty) ? 100 : weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble() +50;
                  final maxY = (weeklyData.values.isEmpty)
                      ? 100.0
                      : weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 50.0;


                  return Column(
                    children: [
                      Card(
                        elevation: 3,
                        child: SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < weeklyData.keys.length) {
                                        return Text(
                                          weeklyData.keys.toList()[index],
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                              ),
                              borderData: FlBorderData(
                                  show: true,
                                  border: const Border(
                                      bottom: BorderSide(),
                                      left: BorderSide())),
                              minX: 0,
                              maxX: (weeklyData.keys.length - 1).toDouble(),
                              minY: 0,
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
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (_, index) {
                            final entry = entries[index];
                            return ListTile(
                              title: Text('${entry.count} steps'),
                              subtitle: Text(entry.date
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _editSteps(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteSteps(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
