import 'dart:io';
import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../db/database_helper.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Profile? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    Profile? p = await DatabaseHelper.instance.getProfile();
    setState(() {
      profile = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: profile == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage:
              AssetImage('assets/profile_default.png'),
            ),
            const SizedBox(height: 20),
            const Text('No profile found'),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Add Profile'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfilePage()),
                );
                _loadProfile();
              },
            ),
          ],
        )
            : Card(
          margin: const EdgeInsets.all(20),
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profile!.imagePath != null
                      ? FileImage(File(profile!.imagePath!))
                      : const AssetImage('assets/profile_default.png')
                  as ImageProvider,
                ),
                const SizedBox(height: 20),
                Text(
                  profile!.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  profile!.profession,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  profile!.contact,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Edit Profile'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              EditProfilePage(profile: profile)),
                    );
                    _loadProfile();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
