import 'package:amozon_app/Homepage/Favorites.dart';
import 'package:amozon_app/chat/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amozon_app/Homepage/Cart.dart';
import 'package:amozon_app/Homepage/Chek.dart';
import 'package:share_plus/share_plus.dart';

class Showpro extends StatefulWidget {
  final String images;
  final String name;
  final String description;
  final String price;
  final QueryDocumentSnapshot productSnapshot;
  final String productId;
  final String productOwner;

  const Showpro({
    super.key,
    required this.description,
    required this.name,
    required this.images,
    required this.price,
    required this.productSnapshot,
    required this.productId,
    required this.productOwner,
  });

  @override
  State<Showpro> createState() => _ShowproState();
}

class _ShowproState extends State<Showpro> {
  int _selectedIndex = 0;

  // في الملف Showpro.dart، تعديل دالة _onItemTapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      final favoritesProvider =
          Provider.of<FavoritesProvider>(context, listen: false);
      final productId = widget.productSnapshot.id;

      if (index == 0) {
        if (favoritesProvider.isFavorite(productId)) {
          favoritesProvider.removeFavorite(widget.productSnapshot);
          _showSnackBar('Removed from favorites');
        } else {
          favoritesProvider.addFavorite(widget.productSnapshot);
          _showSnackBar('Added to favorites');
        }
      } else if (index == 1) {
        _shareProduct();
      } else if (index == 2) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Chatscreen(
                productId: widget.productId,
                productOwner: widget.productOwner,
              ),
            ),
          );
        } else {
          _showSnackBar("يرجى تسجيل الدخول للدردشة مع البائع");
        }
      }
    });
  }

  void _shareProduct() {
    final productUrl =
        "https://yourproducturl.com/product/${widget.productSnapshot.id}";
    Share.share('Check out this amazing product: ${widget.name}\n$productUrl',
        subject: 'Amazing Product on Sale!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final isAdmin = cart.isAdmin;

    return Scaffold(
      floatingActionButton: isAdmin
          ? null
          : Consumer<Cart>(
              builder: (context, cart, child) {
                return FloatingActionButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Cheak()),
                  ),
                  backgroundColor: Colors.orange,
                  child: Stack(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      if (cart.count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text('${cart.count}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.orange,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: 30,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildTitleAndPrice(),
            _buildRatingSection(),
            _buildDescription(),
            _buildBuyNowButton(),
            if (!isAdmin) _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(widget.images,
            fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("\$${widget.price}",
              style: const TextStyle(fontSize: 26, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(5,
            (index) => const Icon(Icons.star, color: Colors.yellow, size: 30)),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(widget.description,
          style: const TextStyle(fontSize: 18, height: 1.5)),
    );
  }

  Widget _buildBuyNowButton() {
    return _buildButton(
        'Buy Now', Colors.red, () => _showSnackBar('Proceeding to buy now'));
  }

  Widget _buildAddToCartButton() {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return _buildButton('Add to Cart', Colors.orange, () async {
          try {
            await cart.addProductToCart(widget.productSnapshot);
            _showSnackBar('Added to cart');
          } catch (e) {
            _showSnackBar(e.toString());
          }
        });
      },
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(text,
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}
