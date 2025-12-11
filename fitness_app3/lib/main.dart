import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/bmi_entry.dart';
import 'models/step_entry.dart';
import 'models/workout.dart';
import 'pages/dashboard_page.dart';
import 'pages/bmi_page.dart';
import 'pages/steps_page.dart';
import 'pages/workouts_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(BMIEntryAdapter());
  Hive.registerAdapter(StepEntryAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  // Open boxes
  await Hive.openBox<BMIEntry>('bmi_entries');
  await Hive.openBox<StepEntry>('steps');
  await Hive.openBox<Workout>('workouts');

  runApp(const FitnessAppPro());
}

class FitnessAppPro extends StatelessWidget {
  const FitnessAppPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    StepsPage(),
    BMIPage(),
    WorkoutsPage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Steps Tracker',
    'BMI Tracker',
    'Workouts',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_walk), label: 'Steps'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_weight), label: 'BMI'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
        ],
      ),
    );
  }
}
