import 'dart:io';
import 'package:amozon_app/Product/Addproduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:amozon_app/auth_screen/login.dart';
import 'package:amozon_app/person/changep.dart';
import 'package:amozon_app/person/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Person extends StatefulWidget {
  const Person({super.key});

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadLanguagePreference();
  }

  String? imageUrl;
  File? file;

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLangCode = prefs.getString('language_code');
    if (savedLangCode != null) {
      setState(() {
        _languageCode = savedLangCode;
      });
    }
  }

  Future<void> _changeLanguage(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    setState(() {
      _languageCode = langCode;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.orangeAccent.shade700,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _languageCode == 'en'
                    ? 'User Profile'
                    : _languageCode == 'fr'
                        ? 'Profil de l\'utilisateur'
                        : 'ملف المستخدم',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orangeAccent.shade700,
                      Colors.orangeAccent.shade400,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orangeAccent.shade700,
                          Colors.orangeAccent.shade400,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl!)
                                : user?.photoURL != null
                                    ? NetworkImage(user!.photoURL!)
                                    : null,
                            child: (imageUrl == null && user?.photoURL == null)
                                ? Icon(Icons.person,
                                    size: 70, color: Colors.grey[300])
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              color: Colors.orangeAccent.shade700,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: getImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user?.displayName ??
                        (_languageCode == 'en'
                            ? 'Unknown User'
                            : _languageCode == 'fr'
                                ? 'Utilisateur Inconnu'
                                : 'مستخدم غير معروف'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _languageCode == 'en'
                              ? 'Language'
                              : _languageCode == 'fr'
                                  ? 'Langue'
                                  : 'اللغة',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildLanguageButton('English', 'en'),
                            const SizedBox(width: 8),
                            _buildLanguageButton('Français', 'fr'),
                            const SizedBox(width: 8),
                            _buildLanguageButton('العربية', 'ar'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOptionCard(
                    icon: Icons.edit,
                    title: _languageCode == 'en'
                        ? 'Edit Profile'
                        : _languageCode == 'fr'
                            ? 'Modifier le profil'
                            : 'تعديل الملف الشخصي',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfile()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    icon: Icons.lock,
                    title: _languageCode == 'en'
                        ? 'Change Password'
                        : _languageCode == 'fr'
                            ? 'Changer le mot de passe'
                            : 'تغيير كلمة المرور',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Changep()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user?.uid == "LBs7mtz6CCQTFe8OLGhy1SWeKXJ3")
                    _buildOptionCard(
                      icon: Icons.add_box,
                      title: _languageCode == 'en'
                          ? 'Add Product'
                          : _languageCode == 'fr'
                              ? 'Ajouter un produit'
                              : 'إضافة منتج',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProduct()),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    icon: Icons.logout,
                    title: _languageCode == 'en'
                        ? 'Log Out'
                        : _languageCode == 'fr'
                            ? 'Se déconnecter'
                            : 'تسجيل الخروج',
                    onTap: () async {
                      await _auth.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String text, String langCode) {
    bool isSelected = _languageCode == langCode;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _changeLanguage(langCode),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.orangeAccent.shade700 : Colors.grey[200],
          disabledBackgroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color ?? Colors.orangeAccent.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }
}
