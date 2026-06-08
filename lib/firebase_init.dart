import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_bug/firebase_options.dart';
import 'package:firebase_auth_bug/localhost.dart';

const int authEmulatorPort = int.fromEnvironment(
  'AUTH_EMULATOR_PORT',
  defaultValue: 0,
);

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (authEmulatorPort > 0) {
    await FirebaseAuth.instance.useAuthEmulator(localhost, authEmulatorPort);
  }
}
