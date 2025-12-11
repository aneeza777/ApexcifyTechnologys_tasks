import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/bmi_entry.dart';

class BMIPage extends StatefulWidget {
  const BMIPage({super.key});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  final _bmiController = TextEditingController();

  void _addBMI({double? value}) {
    final bmiValue = value ?? double.tryParse(_bmiController.text);
    if (bmiValue == null) return;

    final box = Hive.box<BMIEntry>('bmi_entries');
    box.add(BMIEntry(value: bmiValue, date: DateTime.now()));
    _bmiController.clear();
  }

  void _deleteBMI(int index) {
    final box = Hive.box<BMIEntry>('bmi_entries');
    box.getAt(index)?.delete();
  }

  void _editBMI(int index) {
    final box = Hive.box<BMIEntry>('bmi_entries');
    final entry = box.getAt(index);
    if (entry == null) return;

    _bmiController.text = entry.value.toString();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit BMI'),
        content: TextField(
          controller: _bmiController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'BMI Value'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(_bmiController.text);
              if (newValue != null) {
                entry.value = newValue;
                entry.save();
                _bmiController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              _bmiController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _bmiSuggestion(double bmi) {
    if (bmi < 18.5) return 'Underweight - Eat more protein';
    if (bmi < 25) return 'Normal - Maintain your weight';
    if (bmi < 30) return 'Overweight - Exercise more';
    return 'Obese - Consult a doctor';
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<BMIEntry>('bmi_entries');

    return Scaffold(
      appBar: AppBar(title: const Text("BMI Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bmiController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter BMI',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addBMI(),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<BMIEntry> box, _) {
                  final entries = box.values.toList();
                  if (entries.isEmpty) {
                    return const Center(child: Text("No BMI entries yet."));
                  }

                  // Weekly chart data
                  final weeklyData = <String, double>{};
                  for (var e in entries) {
                    final weekDay = "${e.date.month}/${e.date.day}";
                    weeklyData[weekDay] = e.value;
                  }

                  final spots = weeklyData.entries
                      .map((e) => FlSpot(
                      weeklyData.keys.toList().indexOf(e.key).toDouble(),
                      e.value))
                      .toList();

                  final maxY = (weeklyData.values.isEmpty)
                      ? 40.0
                      : weeklyData.values.reduce(
                          (a, b) => a > b ? a : b) +
                      5;

                  return Column(
                    children: [
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                              weeklyData.keys
                                                  .toList()[index],
                                              style: const TextStyle(
                                                  fontSize: 10));
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
                                    color: Colors.deepPurple,
                                    dotData: FlDotData(show: true),
                                  ),
                                ],
                              ),
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
                              title: Text(entry.value.toStringAsFixed(2)),
                              subtitle: Text(
                                  '${entry.date.toLocal().toString().split(' ')[0]} - ${_bmiSuggestion(entry.value)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _editBMI(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteBMI(index),
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
