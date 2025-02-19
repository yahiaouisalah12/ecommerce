import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? imageUrl;
  File? file;

  // اختيار صورة من المعرض
  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        file = File(image.path);
      });

      var imageName = basename(image.path);
      var refImage = FirebaseStorage.instance.ref("images").child(imageName);

      await refImage.putFile(file!);
      imageUrl = await refImage.getDownloadURL();
    }
  }

  // طلب إدخال كلمة المرور الحالية
  Future<String> _getCurrentPassword() async {
    TextEditingController passwordController = TextEditingController();

    // فتح حوار للحصول على كلمة المرور الحالية من المستخدم
    return await showDialog<String>(
          context: this.context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Enter Current Password'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Current Password'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(passwordController.text);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        '';
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      var imageName = basename(imageFile.path);
      var refImage = FirebaseStorage.instance.ref("images").child(imageName);

      await refImage.putFile(imageFile);
      return await refImage.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // تحديث ملف المستخدم
  Future<void> _updateProfile(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    try {
      // إذا كان المستخدم يريد تغيير البريد الإلكتروني، طلب إعادة المصادقة
      if (user.email != email) {
        String currentPassword = await _getCurrentPassword();
        if (currentPassword.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password cannot be empty')),
          );
          return;
        }

        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        // إعادة المصادقة
        await user.reauthenticateWithCredential(credential);

        // بعد المصادقة الناجحة، حاول تحديث البريد الإلكتروني
        await user.updateEmail(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated successfully!')),
        );
      }

      // تحديث الاسم
      await user.updateDisplayName(name);
      if (file != null) {
        String? imageUrl = await _uploadImage(file!);
        if (imageUrl != null) {
          await user.updatePhotoURL(imageUrl);
        }
      }

      // إعادة تحميل معلومات المستخدم بعد التحديث
      await user.reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // صورة الملف الشخصي
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: file != null
                            ? FileImage(file!)
                            : imageUrl != null
                                ? NetworkImage(imageUrl!)
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blueAccent.shade700,
                          radius: 18,
                          child: IconButton(
                            onPressed: getImage,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // حقل الاسم
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.blueAccent.shade700),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.person, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 20),
              // حقل البريد الإلكتروني
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blueAccent.shade700),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 40),
              // زر حفظ التغييرات
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _updateProfile(context); // تمرير context للدالة
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
