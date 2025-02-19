import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool isLoading = false;
  File? file;
  String? imageUrl;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  Future<void> addProduct(BuildContext context) async {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and select an image.")),
      );
      return;
    }

    CollectionReference product =
        FirebaseFirestore.instance.collection("Product");
    try {
      setState(() {
        isLoading = true;
      });

      await product.add({
        "imageUrl": imageUrl ?? "none",
        "name": nameController.text,
        "description": descriptionController.text,
        "price": priceController.text,
        "ownerEmail": FirebaseAuth.instance.currentUser!.email
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add product: $error")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      file = File(image.path);

      var imageName = basename(image.path);
      var refImage = FirebaseStorage.instance.ref("images").child(imageName);

      await refImage.putFile(file!);
      imageUrl = await refImage.getDownloadURL();

      setState(() {});
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // عرض الصورة المحددة
            if (imageUrl != null)
              Center(
                child: Image.network(
                  imageUrl!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Center(
                child: Icon(Icons.image, size: 150, color: Colors.red),
              ),
            const SizedBox(height: 16),
            // زر لاختيار الصورة
            ElevatedButton.icon(
              onPressed: getImage,
              icon: const Icon(Icons.photo_library),
              label: const Text("Choose Product Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // تم استبدال primary بـ backgroundColor
              ),
            ),
            const SizedBox(height: 20),
            // اسم المنتج
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            // وصف المنتج
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Product Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            // سعر المنتج
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Product Price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            // زر إضافة المنتج
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => addProduct(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor:
                          Colors.green, // تم استبدال primary بـ backgroundColor
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Text("Add Product"),
                  ),
          ],
        ),
      ),
    );
  }
}
