// lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const QuoteApp());
}

class QuoteApp extends StatefulWidget {
  const QuoteApp({super.key});

  @override
  State<QuoteApp> createState() => _QuoteAppState();
}

class _QuoteAppState extends State<QuoteApp> {
  ThemeMode mode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("themeMode") ?? "system";

    setState(() {
      mode = saved == "dark"
          ? ThemeMode.dark
          : saved == "light"
          ? ThemeMode.light
          : ThemeMode.system;
    });
  }

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("themeMode", isDark ? "dark" : "light");
    setState(() {
      mode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Random Quote Generator",
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: QuoteHomeScreen(onThemeChange: saveTheme, themeMode: mode),
    );
  }
}

// QUOTE MODEL
class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  Map<String, dynamic> toMap() => {"text": text, "author": author};

  factory Quote.fromMap(Map<String, dynamic> m) {
    return Quote(
      text: m["text"] ?? m["q"] ?? "",
      author: m["author"] ?? m["a"] ?? "Unknown",
    );
  }
}

// MAIN HOME SCREEN
class QuoteHomeScreen extends StatefulWidget {
  final Function(bool) onThemeChange;
  final ThemeMode themeMode;

  const QuoteHomeScreen(
      {super.key, required this.onThemeChange, required this.themeMode});

  @override
  State<QuoteHomeScreen> createState() => _QuoteHomeScreenState();
}

class _QuoteHomeScreenState extends State<QuoteHomeScreen>
    with SingleTickerProviderStateMixin {
  Quote? currentQuote;
  bool loading = false;
  bool useAPI = true;
  Timer? autoRefreshTimer;
  int autoRefreshSeconds = 10;

  List<Quote> favorites = [];
  final Random rng = Random();

  late AnimationController animController;
  late Animation<double> fadeAnim;

  final List<Quote> localQuotes = [
    Quote(
        text: "The best way to predict the future is to create it.",
        author: "Peter Drucker"),
    Quote(text: "Believe you can and you're halfway there.", author: "Roosevelt"),
    Quote(text: "What you think, you become.", author: "Buddha"),
    Quote(text: "Dream big and dare to fail.", author: "Norman Vaughan"),
    Quote(text: "Success is not final, failure is not fatal.",
        author: "Winston Churchill"),
    Quote(
        text: "Simplicity is the ultimate sophistication.",
        author: "Leonardo da Vinci"),
    Quote(
        text: "You miss 100% of the shots you don’t take.",
        author: "Wayne Gretzky"),
    Quote(
        text: "Do one thing every day that scares you.",
        author: "Eleanor Roosevelt"),
  ];

  @override
  void initState() {
    super.initState();

    animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    fadeAnim = CurvedAnimation(parent: animController, curve: Curves.easeInOut);

    loadAppState();
  }

  @override
  void dispose() {
    animController.dispose();
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadAppState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Saved Favorites
    final favList = prefs.getStringList("favorites") ?? [];
    favorites = favList.map((json) => Quote.fromMap(jsonDecode(json))).toList();

    // Load last quote
    final lastSaved = prefs.getString("lastQuote");
    if (lastSaved != null) {
      currentQuote = Quote.fromMap(jsonDecode(lastSaved));
    }

    await newQuote();

    // Auto-refresh
    autoRefreshTimer?.cancel();
    autoRefreshTimer =
        Timer.periodic(Duration(seconds: autoRefreshSeconds), (_) => newQuote());
  }

  Future<Quote?> fetchOnlineQuote() async {
    try {
      final url = Uri.parse("https://zenquotes.io/api/random");
      final response = await http.get(url).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body);
        return Quote(
          text: list[0]["q"],
          author: list[0]["a"],
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> newQuote() async {
    if (loading) return;

    loading = true;
    animController.reverse();

    Quote? q;

    if (useAPI) q = await fetchOnlineQuote();

    q ??= localQuotes[rng.nextInt(localQuotes.length)];

    setState(() => currentQuote = q);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString("lastQuote", jsonEncode(q.toMap()));

    loading = false;
    animController.forward(from: 0.0);
  }

  void toggleFavorite() async {
    if (currentQuote == null) return;

    final exists = favorites.any((x) => x.text == currentQuote!.text);

    if (exists) {
      favorites.removeWhere((x) => x.text == currentQuote!.text);
    } else {
      favorites.insert(0, currentQuote!);
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        "favorites", favorites.map((q) => jsonEncode(q.toMap())).toList());

    setState(() {}); // immediate rebuild
  }

  void copyQuote() {
    if (currentQuote == null) return;

    Clipboard.setData(
        ClipboardData(text: '"${currentQuote!.text}" — ${currentQuote!.author}'));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  void shareQuote() {
    if (currentQuote == null) return;

    Share.share('"${currentQuote!.text}" — ${currentQuote!.author}');
  }

  void openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesPage(
          favorites: favorites,
          onSelect: (q) {
            setState(() {
              currentQuote = q;
            });
            Navigator.pop(context);
          },
          onRemove: (q) async {
            favorites.removeWhere((x) => x.text == q.text);
            final prefs = await SharedPreferences.getInstance();
            prefs.setStringList(
                "favorites", favorites.map((e) => jsonEncode(e.toMap())).toList());
            setState(() {}); // immediate rebuild
          },
        ),
      ),
    );
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          initialSeconds: autoRefreshSeconds,
          onSave: (sec) {
            setState(() {
              autoRefreshSeconds = sec; // immediate update on main page
            });
            autoRefreshTimer?.cancel();
            autoRefreshTimer =
                Timer.periodic(Duration(seconds: sec), (_) => newQuote());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Random Quote Generator"),
        actions: [
          IconButton(
              icon: Icon(isDark ? Icons.sunny : Icons.dark_mode),
              onPressed: () => widget.onThemeChange(!isDark)),
          PopupMenuButton(
            onSelected: (value) {
              if (value == "favorites") openFavorites();
              if (value == "settings") openSettings();
              if (value == "toggleAPI") {
                setState(() => useAPI = !useAPI);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: "toggleAPI",
                child: Row(
                  children: [
                    Checkbox(value: useAPI, onChanged: (_) {}),
                    const Text("Use API when online"),
                  ],
                ),
              ),
              const PopupMenuItem(
                  value: "favorites", child: Text("Favorites")),
              const PopupMenuItem(
                  value: "settings", child: Text("Settings")),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black87, Colors.deepPurple.shade900]
                : [Colors.deepPurple.shade400, Colors.deepPurple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: currentQuote == null
              ? const CircularProgressIndicator()
              : FadeTransition(
            opacity: fadeAnim,
            child: Card(
              margin: const EdgeInsets.all(20),
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.format_quote,
                          size: 60, color: Colors.deepPurple),
                      const SizedBox(height: 20),
                      Text(
                        currentQuote!.text,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "- ${currentQuote!.author}",
                        style: const TextStyle(
                            fontSize: 18, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 10,
                        children: [
                          ElevatedButton.icon(
                              onPressed: newQuote,
                              icon: const Icon(Icons.refresh),
                              label: const Text("New Quote")),
                          OutlinedButton.icon(
                              onPressed: shareQuote,
                              icon: const Icon(Icons.share),
                              label: const Text("Share")),
                          OutlinedButton.icon(
                              onPressed: copyQuote,
                              icon: const Icon(Icons.copy),
                              label: const Text("Copy")),
                          OutlinedButton.icon(
                              onPressed: toggleFavorite,
                              icon: Icon(favorites.any(
                                      (q) => q.text == currentQuote!.text)
                                  ? Icons.favorite
                                  : Icons.favorite_border),
                              label: const Text("Favorite")),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Auto-refresh: $autoRefreshSeconds seconds",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// FAVORITES PAGE (NOW STATEFUL)
class FavoritesPage extends StatefulWidget {
  final List<Quote> favorites;
  final Function(Quote) onRemove;
  final Function(Quote) onSelect;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onRemove,
    required this.onSelect,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Quote> localFavorites;

  @override
  void initState() {
    super.initState();
    localFavorites = List.from(widget.favorites);
  }

  void removeFavorite(Quote q) {
    setState(() {
      localFavorites.removeWhere((item) => item.text == q.text);
    });
    widget.onRemove(q); // update parent immediately
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: localFavorites.isEmpty
          ? const Center(child: Text("No favorites yet"))
          : ListView.builder(
        itemCount: localFavorites.length,
        itemBuilder: (_, i) {
          final q = localFavorites[i];
          return ListTile(
            title: Text(q.text),
            subtitle: Text(q.author),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => removeFavorite(q),
            ),
            onTap: () => widget.onSelect(q),
          );
        },
      ),
    );
  }
}

// SETTINGS PAGE
class SettingsPage extends StatefulWidget {
  final int initialSeconds;
  final Function(int) onSave;

  const SettingsPage(
      {super.key, required this.initialSeconds, required this.onSave});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int seconds;

  @override
  void initState() {
    super.initState();
    seconds = widget.initialSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Auto Refresh Interval (seconds)",
                style: TextStyle(fontSize: 16)),
            Slider(
              min: 5,
              max: 60,
              divisions: 11,
              value: seconds.toDouble(),
              label: "$seconds seconds",
              onChanged: (v) => setState(() => seconds = v.toInt()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  widget.onSave(seconds);
                  Navigator.pop(context);
                },
                child: const Text("Save Settings"))
          ],
        ),
      ),
    );
  }
}
