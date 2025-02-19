import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final List<QueryDocumentSnapshot> _favorites = [];

  // إضافة عنصر إلى قائمة المفضلة
  void addFavorite(QueryDocumentSnapshot item) {
    if (!_favorites.any((fav) => fav.id == item.id)) {
      _favorites.add(item);
      notifyListeners();
    }
  }

  // إزالة عنصر من قائمة المفضلة
  void removeFavorite(QueryDocumentSnapshot item) {
    _favorites.removeWhere((fav) => fav.id == item.id);
    notifyListeners();
  }

  // التحقق إذا كان المنتج مفضلاً
  bool isFavorite(String productId) {
    return _favorites.any((item) => item.id == productId);
  }

  // جلب قائمة المفضلات
  List<QueryDocumentSnapshot> get FavoriteItems {
    return _favorites;
  }
}
