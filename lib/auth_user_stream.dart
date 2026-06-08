import 'package:firebase_auth/firebase_auth.dart';

/// Uses [FirebaseAuth.authStateChanges] — typical app setup that reproduces
/// multi-tab logout on web when a second tab opens.
Stream<User?> authUserStream(FirebaseAuth firebaseAuth) =>
    firebaseAuth.authStateChanges();
