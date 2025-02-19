import 'package:amozon_app/Homepage/Cart.dart';
import 'package:amozon_app/Homepage/Favorites.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'homepage/tapbar.dart';
import 'homepage/page1.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // يمكنك هنا إضافة معالجة الخطأ المناسبة
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // مراقبة حالة تسجيل الدخول
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in! UID: ${user.uid}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => Cart()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My App', // إضافة عنوان للتطبيق
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // يمكنك تخصيص السمات هنا
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'حدث خطأ: ${snapshot.error}',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
            }

            return snapshot.hasData ? const Tabe() : const Page1();
          },
        ),
      ),
    );
  }
}
