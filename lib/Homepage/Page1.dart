import 'package:amozon_app/auth_screen/Login.dart';
import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  void initState() {
    super.initState();
    // تأخير لمدة 3 ثواني قبل الانتقال إلى الصفحة التالية
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Login()), // استبدل بـ NextPage بالصفحة التي تريد الانتقال إليها
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[800],
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 120,
                    color: Colors.white,
                    width: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'icons/app_logo.png',
                        height: 100,
                        width: 70,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "eMart",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  const Text(
                    "version 1.0.0",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "@Baaba Devs",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
