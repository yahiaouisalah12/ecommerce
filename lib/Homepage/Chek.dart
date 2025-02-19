import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amozon_app/Homepage/Cart.dart';

class Cheak extends StatefulWidget {
  const Cheak({super.key});

  @override
  State<Cheak> createState() => _CheakState();
}

class _CheakState extends State<Cheak> {
  @override
  void initState() {
    super.initState();
    Provider.of<Cart>(context, listen: false).loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);

    // Redirect admin users away from cart page
    if (cart.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart Access Denied'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: Text(
            'Admin users cannot access the cart',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cart Items'),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<Cart>(
        builder: (context, cart, child) {
          if (cart.cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            );
          }

          return ListView.builder(
            itemCount: cart.cartItems.length,
            itemBuilder: (context, index) {
              final product = cart.cartItems[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product['imageUrl'] ?? '',
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "\$${double.tryParse(product['price'].toString())?.toStringAsFixed(2) ?? '0.00'}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () async {
                          await cart.removeProductFromCart(product);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
