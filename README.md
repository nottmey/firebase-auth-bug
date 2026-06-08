# Firebase Auth web multi-tab repro

**Web-only** minimal Flutter app to reproduce **both browser tabs logging out when a second tab opens** bug.

## Prerequisites

- Flutter 3.41.x
- Chrome
- Firebase CLI (`firebase emulators:start`)

## Run

### via VS Code / Cursor

**Run and Debug** → **firebase_auth_bug: auth emulator + web**

Chrome opens at `http://localhost:7357`.

### or via CLI

```bash
cd firebase-auth-bug
flutter pub get

# Terminal 1
firebase emulators:start --only auth

# Terminal 2
flutter run -d chrome --web-port=7357 \
  --dart-define=AUTH_EMULATOR_PORT=9099
```

## Reproduction steps

1. Sign in (`test@example.com` / `password` on the emulator).
2. Confirm the log shows `stream→uid=…`.
3. **Do not reload tab 1.**
4. Open a **duplicate tab** (in-app button or same URL).
5. Tab 1 logs red `stream→null`; both tabs show signed out.
6. DevTools → Application → IndexedDB → `firebaseLocalStorage` → `fbase_key` is gone.
