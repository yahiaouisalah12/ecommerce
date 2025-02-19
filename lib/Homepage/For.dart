import 'package:amozon_app/Homepage/Favorites.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  void _loadFavoriteProducts() {
    // إذا كان هناك أي منطق تحميل إضافي، يمكن إضافته هنا
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Favorite Products'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<FavoritesProvider>(builder: (context, favorite, child) {
        if (favorite.FavoriteItems.isEmpty) {
          return const Center(
            child: Text(
              'No favorite products',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // عدد الأعمدة
            crossAxisSpacing: 10, // المسافة الأفقية بين العناصر
            mainAxisSpacing: 10, // المسافة العمودية بين العناصر
            childAspectRatio: 0.55, // نسبة العرض إلى الارتفاع للعناصر
          ),
          itemCount: favorite.FavoriteItems.length,
          itemBuilder: (context, index) {
            final favoriteItem =
                favorite.FavoriteItems[index].data() as Map<String, dynamic>;

            return Card(
              elevation: 5, // Adds shadow to the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض صورة المنتج
                    Stack(
                      children: [
                        Image.network(
                          favoriteItem['imageUrl'] ?? '',
                          height: 150, // حجم الصورة
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Center(
                                child:
                                    Icon(Icons.image_not_supported, size: 50),
                              ),
                            );
                          },
                        ),
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favoriteItem['name'] ?? 'Unknown Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis, // قص النص إذا كان طويلًا
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "\$${double.tryParse(favoriteItem['price'].toString())?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // يمكنك إضافة منطق لشراء المنتج هنا
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Center(
                              child: Text(
                                'Buy Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
