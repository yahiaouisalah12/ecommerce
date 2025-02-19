import 'package:amozon_app/proprtiesProduct/Showpro.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<String> images = [
    "images/slider_2.png",
    "images/slider_3.png",
    "images/slider_4.png",
    "images/ss1.jpg",
  ];

  Stream<QuerySnapshot> getData() {
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

  Widget _show() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                images[i],
                height: 160,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _images() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                images[i],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _showProduct() {
    return StreamBuilder<QuerySnapshot>(
      stream: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("No products available")),
          );
        }

        var data = snapshot.data!.docs;

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              var productData = data[i];

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Showpro(
                        description: productData["description"],
                        name: productData["name"],
                        images: productData["imageUrl"],
                        price: "\$${productData["price"]}",
                        productSnapshot: productData,
                        productId: productData.id,
                        productOwner:
                            (productData.data() as Map<String, dynamic>?)
                                        ?.containsKey('ownerEmail') ==
                                    true
                                ? productData["ownerEmail"]
                                : "Owner not available",
                      ),
                    ));
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            productData["imageUrl"] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: const Center(
                                    child: Text("Image not available")),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          productData["name"] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          productData["description"] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "\$${productData["price"]}",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: data.length,
          ),
        );
      },
    );
  }

  Widget _categoryCard(String iconPath, String title, {Color? iconColor}) {
    return Container(
      width: 150,
      height: 100,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 30,
            color: iconColor,
          ),
          const SizedBox(height: 5),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 35),
              child: InkWell(
                onTap: () {
                  showSearch(context: context, delegate: Searchcustomer());
                },
                child: Container(
                  height: 50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text("Search anything"),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.search, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(height: 130, child: _images()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Row(
                children: [
                  _categoryCard("icons/todays_deal.png", "Today's Deal"),
                  const SizedBox(width: 10),
                  _categoryCard(
                    "icons/flash_deal.png",
                    "Flash Deal",
                    iconColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 47),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Featured Categories",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: _showProduct(),
          ),
        ],
      ),
    );
  }
}

// Search Functionality

class Searchcustomer extends SearchDelegate {
  Stream<QuerySnapshot> searchProducts(String query) {
    return FirebaseFirestore.instance
        .collection("Product")
        .where('name', isGreaterThanOrEqualTo: query)
        .snapshots();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = ''; // Clear search text
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null); // Close search interface
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        var results = snapshot.data!.docs;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, i) {
            var productData = results[i];

            return ListTile(
              title: Text(productData['name']),
              subtitle: Text("\$${productData['price']}"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Showpro(
                    description: productData["description"],
                    name: productData["name"],
                    images: productData["imageUrl"],
                    price: "\$${productData["price"]}",
                    productSnapshot: productData,
                    productId: productData.id,
                    productOwner: (productData.data() as Map<String, dynamic>?)
                                ?.containsKey('ownerEmail') ==
                            true
                        ? productData["ownerEmail"]
                        : "Owner not available",
                  ),
                ));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty
        ? const Center(child: Text("Enter a product name"))
        : StreamBuilder<QuerySnapshot>(
            stream: searchProducts(query),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No products found"));
              }

              var data = snapshot.data!.docs;

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, i) {
                  var productData = data[i];

                  return Card(
                    child: ListTile(
                      title: Text(productData["name"]),
                      subtitle: Text(productData["description"]),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Showpro(
                            description: productData["description"],
                            name: productData["name"],
                            images: productData["imageUrl"],
                            price: "\$${productData["price"]}",
                            productSnapshot: productData,
                            productId: productData.id,
                            productOwner:
                                (productData.data() as Map<String, dynamic>?)
                                            ?.containsKey('ownerEmail') ==
                                        true
                                    ? productData["ownerEmail"]
                                    : "Owner not available",
                          ),
                        ));
                      },
                    ),
                  );
                },
              );
            },
          );
  }
}
