import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Cart extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<QueryDocumentSnapshot> _cartItems = [];

  // Check if current user is admin
  bool get isAdmin {
    final user = _auth.currentUser;
    return user?.uid == "LBs7mtz6CCQTFe8OLGhy1SWeKXJ3";
  }

  Future<void> loadCartItems() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection("carts")
        .doc(user.uid)
        .collection("items")
        .get();

    _cartItems = snapshot.docs;
    notifyListeners();
  }

  Future<void> addProductToCart(QueryDocumentSnapshot product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Prevent admin from adding to cart
    if (isAdmin) {
      throw Exception("Admin cannot add items to cart");
    }

    await _firestore
        .collection("carts")
        .doc(user.uid)
        .collection("items")
        .doc(product.id)
        .set(product.data() as Map<String, dynamic>);

    await loadCartItems();
  }

  Future<void> removeProductFromCart(QueryDocumentSnapshot product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("carts")
        .doc(user.uid)
        .collection("items")
        .doc(product.id)
        .delete();

    await loadCartItems();
  }

  int get count => _cartItems.length;
  List<QueryDocumentSnapshot> get cartItems => _cartItems;
}
