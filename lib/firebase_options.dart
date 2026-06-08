// Firebase project: firebase-auth-bug (Auth emulator + web repro).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb) {
      throw UnsupportedError(
        'firebase_auth_bug is a web-only repro. Run: flutter run -d chrome',
      );
    }
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbAFoZlC3nQo3EVzBIsmyGLsUCbAIZeI0',
    appId: '1:809486347085:web:1ff3e9986ce75aec40e504',
    messagingSenderId: '809486347085',
    projectId: 'firebase-auth-bug',
    authDomain: 'fir-auth-bug-9b208.firebaseapp.com',
    storageBucket: 'firebase-auth-bug.firebasestorage.app',
  );

}