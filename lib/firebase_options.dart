// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDIPIlyWHeX-804EpbwB86R5RhvTIZWVH4',
    appId: '1:204475737814:web:4ba1b976365b8dff610b77',
    messagingSenderId: '204475737814',
    projectId: 'amozon-a65d8',
    authDomain: 'amozon-a65d8.firebaseapp.com',
    storageBucket: 'amozon-a65d8.appspot.com',
    measurementId: 'G-40YT16QJPE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_TiK1epCxh3Ns4OhdE_J6IIkV8uwKoa0',
    appId: '1:204475737814:android:3db78ba14423c38c610b77',
    messagingSenderId: '204475737814',
    projectId: 'amozon-a65d8',
    storageBucket: 'amozon-a65d8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFiPEOxaPd9ukOXpK9pLp5TvGrBebctv8',
    appId: '1:204475737814:ios:0f20c62d4495a6d4610b77',
    messagingSenderId: '204475737814',
    projectId: 'amozon-a65d8',
    storageBucket: 'amozon-a65d8.appspot.com',
    iosBundleId: 'com.example.amozonApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDFiPEOxaPd9ukOXpK9pLp5TvGrBebctv8',
    appId: '1:204475737814:ios:0f20c62d4495a6d4610b77',
    messagingSenderId: '204475737814',
    projectId: 'amozon-a65d8',
    storageBucket: 'amozon-a65d8.appspot.com',
    iosBundleId: 'com.example.amozonApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDIPIlyWHeX-804EpbwB86R5RhvTIZWVH4',
    appId: '1:204475737814:web:821e17a6a2b4e053610b77',
    messagingSenderId: '204475737814',
    projectId: 'amozon-a65d8',
    authDomain: 'amozon-a65d8.firebaseapp.com',
    storageBucket: 'amozon-a65d8.appspot.com',
    measurementId: 'G-B7Z9ZC2KJP',
  );
}
