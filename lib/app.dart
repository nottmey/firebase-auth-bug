import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_bug/auth_user_stream.dart';
import 'package:firebase_auth_bug/utils/open_tab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final List<String> _eventLog = [];
  StreamSubscription<User?>? _authSubscription;
  User? _streamUser;
  String? _liveCurrentUserUid;

  @override
  void initState() {
    super.initState();
    _listenToAuth();
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  void _listenToAuth() {
    unawaited(_authSubscription?.cancel());
    _authSubscription = authUserStream(FirebaseAuth.instance).listen((user) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final streamLabel = user == null ? 'null' : 'uid=${user.uid}';
      final currentLabel =
          currentUser == null ? 'null' : 'uid=${currentUser.uid}';
      final mismatch = user?.uid != currentUser?.uid;
      final message =
          '${DateTime.now().toIso8601String()} stream→$streamLabel | '
          'currentUser→$currentLabel'
          '${mismatch ? ' ⚠ MISMATCH' : ''}';
      setState(() {
        _streamUser = user;
        _liveCurrentUserUid = currentUser?.uid;
        _eventLog.insert(0, message);
        if (_eventLog.length > 40) {
          _eventLog.removeRange(40, _eventLog.length);
        }
      });
    });
  }

  String get _pageUrl => Uri.base.replace(fragment: '').toString();

  Future<void> _signIn() async {
    const email = 'test@example.com';
    const password = 'password';
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') {
        rethrow;
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _openDuplicateTab() {
    if (!kIsWeb) {
      return;
    }
    openDuplicateTab(_pageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final streamSignedIn = _streamUser != null;
    final statusLine = streamSignedIn
        ? 'UI: signed in (stream uid=${_streamUser!.uid})'
        : 'UI: signed out (stream is null)';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('authStateChanges() repro'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Listens to FirebaseAuth.authStateChanges() only. '
                'Sign in, then open a duplicate tab without reloading tab 1 — '
                'both tabs often sign out when IndexedDB is cleared.',
              ),
              const SizedBox(height: 8),
              Text(statusLine, style: Theme.of(context).textTheme.titleMedium),
              Text(
                'FirebaseAuth.instance.currentUser: '
                '${_liveCurrentUserUid ?? 'null'}',
              ),
              const SizedBox(height: 12),
              const Text('Repro steps'),
              const SizedBox(height: 4),
              const Text(
                '1. Sign in → stream→uid=…\n'
                '2. Do not reload tab 1\n'
                '3. Open duplicate tab\n'
                '4. Tab 1: red stream→null; both tabs may show signed out\n'
                '5. DevTools → IndexedDB → firebaseLocalStorage → fbase_key gone',
              ),
              const SizedBox(height: 8),
              SelectableText(
                _pageUrl,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(onPressed: _signIn, child: const Text('Sign in')),
                  OutlinedButton(onPressed: _signOut, child: const Text('Sign out')),
                  if (kIsWeb)
                    FilledButton.tonal(
                      onPressed: _openDuplicateTab,
                      child: const Text('Open duplicate tab'),
                    ),
                  if (kIsWeb)
                    OutlinedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _pageUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('URL copied')),
                        );
                      },
                      child: const Text('Copy URL'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Auth events (newest first) — red = stream emitted null',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _eventLog.isEmpty
                      ? const Center(
                          child: Text('No auth events yet — sign in first'),
                        )
                      : ListView.builder(
                          itemCount: _eventLog.length,
                          itemBuilder: (context, index) {
                            final line = _eventLog[index];
                            final isNull = line.contains('stream→null');
                            return ListTile(
                              dense: true,
                              title: Text(
                                line,
                                style: TextStyle(
                                  color: isNull ? Colors.red : null,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
