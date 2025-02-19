import 'package:flutter/material.dart';
import 'package:amozon_app/Homepage/Categersie.dart';
import 'package:amozon_app/Homepage/Chek.dart';
import 'package:amozon_app/Homepage/For.dart';
import 'package:amozon_app/Homepage/Page2.dart';
import 'package:amozon_app/Homepage/Person.dart';

class Tabe extends StatefulWidget {
  const Tabe({super.key});

  @override
  State<Tabe> createState() => _TabState();
}

class _TabState extends State<Tabe> {
  final List<Widget> _screen = [
    const Page2(),
    const Categersie(),
    const Cheak(),
    const FavoritesPage(),
    const Person(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screen[_selectedIndex],
          // Add a subtle gradient overlay at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            iconSize: 28,
            selectedItemColor: Colors.orangeAccent.shade700,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            items: [
              _buildNavItem(Icons.home_rounded, "Home"),
              _buildNavItem(Icons.category_rounded, "Categories"),
              _buildNavItem(Icons.shopping_cart_rounded, "Cart"),
              _buildNavItem(Icons.favorite_rounded, "Favorite"),
              _buildNavItem(Icons.person_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Icon(
          icon,
          size: 32,
        ),
      ),
      label: label,
    );
  }
}
