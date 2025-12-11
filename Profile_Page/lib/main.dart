import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ApexcifyTechnology Profile",
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {

  String name = "ApexcifyTechnology";
  String email = "apex.technology@gmail.com";
  String bio = "We build modern mobile & web applications.";

  ImageProvider? profileImage;

  final picker = ImagePicker();

  // Animation
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    initAnim();
    loadProfile();
  }

  void initAnim() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutBack);
    controller.forward();
  }

  // ---------------- LOAD PROFILE --------------------
  Future<void> loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? name;
      email = prefs.getString("email") ?? email;
      bio = prefs.getString("bio") ?? bio;

      String? img64 = prefs.getString("profileImage");
      if (img64 != null) {
        profileImage = MemoryImage(base64Decode(img64));
      }
    });
  }

  // ---------------- SAVE PROFILE --------------------
  Future<void> saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("bio", bio);
  }

  // ---------------- PICK IMAGE -----------------------
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    Uint8List bytes = await image.readAsBytes();
    String base64Img = base64Encode(bytes);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("profileImage", base64Img);

    setState(() {
      profileImage = MemoryImage(bytes);
    });
  }

  // ---------------- EDIT PROFILE DIALOG ---------------------
  void openEditDialog() {
    final nameCtrl = TextEditingController(text: name);
    final emailCtrl = TextEditingController(text: email);
    final bioCtrl = TextEditingController(text: bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: profileImage ??
                        const NetworkImage("https://i.pravatar.cc/150"),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: "Bio"), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                name = nameCtrl.text;
                email = emailCtrl.text;
                bio = bioCtrl.text;
              });

              await saveProfile();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ---------------- UI ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Profile Image With Edit Icon
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage ??
                            const NetworkImage("https://i.pravatar.cc/150"),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child:
                            const Icon(Icons.edit, size: 20, color: Colors.blue),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  // Bio Card (Glassmorphism)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Info Cards
                  buildInfoCard(Icons.person, "Name", name),
                  buildInfoCard(Icons.email, "Email", email),
                  buildInfoCard(Icons.info, "Bio", bio),
                ],
              ),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openEditDialog,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title),
          subtitle: Text(value),
        ),
      ),
    );
  }
}
