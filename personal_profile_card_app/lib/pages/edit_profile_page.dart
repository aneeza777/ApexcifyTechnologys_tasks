import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';
import '../models/profile.dart';

class EditProfilePage extends StatefulWidget {
  final Profile? profile;
  const EditProfilePage({super.key, this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController professionController;
  late TextEditingController contactController;
  String? imagePath;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.profile?.name ?? '');
    professionController =
        TextEditingController(text: widget.profile?.profession ?? '');
    contactController =
        TextEditingController(text: widget.profile?.contact ?? '');
    imagePath = widget.profile?.imagePath;
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    Profile p = Profile(
      id: widget.profile?.id,
      name: nameController.text,
      profession: professionController.text,
      contact: contactController.text,
      imagePath: imagePath,
    );
    if (widget.profile == null) {
      await DatabaseHelper.instance.insertProfile(p);
    } else {
      await DatabaseHelper.instance.updateProfile(p);
    }
    Navigator.pop(context); // return to profile page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: imagePath != null
                    ? FileImage(File(imagePath!))
                    : const AssetImage('assets/profile_default.png')
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: professionController,
              decoration: const InputDecoration(labelText: 'Profession'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact Info'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
