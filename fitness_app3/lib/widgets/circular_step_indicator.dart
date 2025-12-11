import 'package:flutter/material.dart';

class CircularStepIndicator extends StatelessWidget {
  final int steps;
  final int goal;

  const CircularStepIndicator({super.key, required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    double progress = (steps / goal).clamp(0.0, 1.0);

    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$steps",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text("steps", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
