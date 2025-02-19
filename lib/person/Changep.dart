import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Changep extends StatefulWidget {
  const Changep({super.key});

  @override
  State<Changep> createState() => _ChangepState();
}

class _ChangepState extends State<Changep> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // إعادة تسجيل الدخول باستخدام كلمة المرور القديمة
      String oldPassword = _oldPasswordController.text;
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: oldPassword);

      try {
        // تسجيل الدخول
        await user.reauthenticateWithCredential(credential);

        // التحقق من تطابق كلمة المرور الجديدة
        if (_newPasswordController.text == _confirmPasswordController.text) {
          // تغيير كلمة المرور
          await user.updatePassword(_newPasswordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New passwords do not match!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Update Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Old Password
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(color: Colors.blueAccent.shade700),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 20),
              // New Password
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.blueAccent.shade700),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 20),
              // Confirm New Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: Colors.blueAccent.shade700),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.lock_rounded, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Change Password',
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
