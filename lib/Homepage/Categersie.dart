import 'package:amozon_app/proprtiesProduct/Showpro.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Categersie extends StatefulWidget {
  const Categersie({super.key});

  @override
  State<Categersie> createState() => _CategersieState();
}

class _CategersieState extends State<Categersie> {
  Stream<QuerySnapshot> getdata() {
    return FirebaseFirestore.instance.collection("Product").snapshots();
  }

  Future<void> deleteProduct(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Product")
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete product: $error")),
      );
    }
  }

  Widget _showProduct() {
    return StreamBuilder<QuerySnapshot>(
      stream: getdata(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products available"));
        }

        var data = snapshot.data!.docs;

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: data.length,
            itemBuilder: (context, i) {
              var productData = data[i];

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Showpro(
                            description: productData["description"],
                            name: productData["name"],
                            images: productData["imageUrl"],
                            price: "\$${productData["price"]}",
                            productSnapshot: productData,
                            productId: productData.id, // تمرير معرف المنتج
                            productOwner: productData[
                                "ownerEmail"], // تمرير إيميل صاحب المنتج
                          )));
                },
                onLongPress: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.rightSlide,
                    title: "Warning",
                    desc: "هل أنت متأكد من عملية الحذف؟",
                    btnOkText: "Delete",
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async {
                      await deleteProduct(productData.id);
                    },
                  ).show();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          productData["imageUrl"] as String,
                          fit: BoxFit.cover,
                          height: 160,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(
                                  child: Text("Image not available")),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productData["name"] as String,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              productData["description"] as String,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "\$${productData["price"]}",
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: const Text("Categories"),
            floating: true,
            expandedHeight: 70,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.orangeAccent,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _showProduct(),
          ),
        ],
      ),
    );
  }
}
