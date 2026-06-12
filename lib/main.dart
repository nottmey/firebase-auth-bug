import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_bug/app.dart';
import 'package:firebase_auth_bug/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const int _authEmulatorPort = int.fromEnvironment(
  'AUTH_EMULATOR_PORT',
  defaultValue: 0,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_authEmulatorPort > 0) {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', _authEmulatorPort);
  }
  runApp(const App());
}
