// File generated and managed by the FlutterFire CLI.
// Run `flutterfire configure` from the project root to regenerate this file
// with your own Firebase project's real values before running the app.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run `flutterfire configure` to add support for it.',
        );
    }
  }

  // TODO(flutterfire-configure): replace all values below by running:
  //   dart pub global activate flutterfire_cli
  //   flutterfire configure

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBsE9PEZZjfoD5RqkIjKuSk7hkYvMMyMA0',
    appId: '1:589771449105:web:4efeeded813bfa82cd22b0',
    messagingSenderId: '589771449105',
    projectId: 'petpaws-e1f6f',
    authDomain: 'petpaws-e1f6f.firebaseapp.com',
    storageBucket: 'petpaws-e1f6f.firebasestorage.app',
    measurementId: 'G-9ZRZ1K8CN6',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );
}
