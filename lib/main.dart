import 'package:firebase_auth_bug/firebase_init.dart';
import 'package:firebase_auth_bug/app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const App());
}
