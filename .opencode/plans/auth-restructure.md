# Plan: Restructure Auth Feature to Clean Architecture

## Context
The authentication logic is currently scattered across `lib/services/` (auth_service.dart, pin_service.dart), `lib/screens/` (login_screen, otp_screen, phone_number_screen, pin_screen), `lib/main.dart` (AuthGate, _PinGate), and `lib/widgets/login/` (4 small widgets). The user wants it restructured into clean architecture under `lib/features/authentication/` following the same pattern as `lib/features/voice_command/`. **No UI changes** — only structural reorganization.

## Target Structure
```
lib/features/authentication/
├── domain/
│   ├── entities/
│   │   └── user.dart
│   └── repositories/
│       ├── auth_repository.dart
│       └── pin_repository.dart
├── data/
│   ├── repositories/
│   │   ├── auth_repository_impl.dart
│   │   └── pin_repository_impl.dart
│   └── providers/
│       └── auth_providers.dart
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart
    │   └── auth_state.dart
    ├── screens/
    │   ├── auth_gate.dart
    │   ├── login_screen.dart
    │   ├── otp_screen.dart
    │   ├── phone_number_screen.dart
    │   └── pin_screen.dart
    └── widgets/
        └── login/
            ├── animated_logo.dart
            ├── welcome_header.dart
            ├── language_selector.dart
            └── login_footer.dart
```

## Step-by-Step Plan

### Step 1 — Domain Layer (3 files)

**Create `domain/entities/user.dart`**
- `User` class with `uid`, `phoneNumber`, `displayName` fields
- `const` constructor + `copyWith()`
- Package-level doc header matching voice_command convention

**Create `domain/repositories/auth_repository.dart`**
- Abstract class `AuthRepository` with:
  - `User? get currentUser`
  - `Stream<User?> get authStateChanges`
  - `Future<void> verifyPhoneNumber({...})`
  - `Future<UserCredential> verifySmsCode({...})`
  - `Future<void> signOut()`
- ARCHITECTURE RULE comment: no data/presentation imports

**Create `domain/repositories/pin_repository.dart`**
- Abstract class `PinRepository` with:
  - `Future<void> savePin({uid, pin, name, phone})`
  - `Future<bool> hasPin(String uid)`
  - `Future<bool> validatePin({uid, pin})`
  - `Future<Map<String, String>?> getUserProfile(String uid)`
  - `Future<void> clearPin(String uid)`

### Step 2 — Data Layer (3 files)

**Create `data/repositories/auth_repository_impl.dart`**
- `AuthRepositoryImpl implements AuthRepository`
- Wraps `FirebaseAuth` (same logic as current `AuthService`)
- Does NOT handle sign-out side effects (DB close, provider invalidation) — that stays in the provider

**Create `data/repositories/pin_repository_impl.dart`**
- `PinRepositoryImpl implements PinRepository`
- Wraps `FlutterSecureStorage` + `FirebaseFirestore` (same logic as current `PinService`)

**Create `data/providers/auth_providers.dart`**
- `authRepositoryProvider` → `Provider<AuthRepository>` → `AuthRepositoryImpl()`
- `pinRepositoryProvider` → `Provider<PinRepository>` → `PinRepositoryImpl()`
- `authStateProvider` → `StreamProvider<User?>` from `authRepository.authStateChanges`
- These replace the global providers currently in `lib/services/auth_service.dart`

### Step 3 — Auth State + Provider (2 files)

**Create `presentation/providers/auth_state.dart`**
- `AuthStep` enum: `phone, otp, pinSetup, pinEntry, complete`
- `AuthState` class with:
  - `step`, `phoneNumber`, `verificationId`, `resendToken`
  - `loading`, `error`, `resendSeconds`
  - `hasPin`, `pinVerified`, `pinSetupComplete`
  - `userId`, `userName`, `userPhone`
  - `otpKey` (int, incremented to force OTP screen rebuild)
  - `copyWith()` with clear flags

**Create `presentation/providers/auth_provider.dart`**
- `authProvider` → `StateNotifierProvider.autoDispose<AuthNotifier, AuthState>`
- Wires: `authRepository`, `pinRepository`, global providers (`customersProvider`, `syncProvider`, etc.)
- `AuthNotifier extends StateNotifier<AuthState>`:
  - `initForUser(uid)` → check hasPin, getUserProfile, route to correct step
  - `sendOtp(phone)` → calls `authRepository.verifyPhoneNumber`, manages timer
  - `verifyOtp(code)` → calls `authRepository.verifySmsCode`
  - `resendOtp()` → resends
  - `submitPin(pin)` → on pinSetup → savePin; on pinEntry → validatePin
  - `resetError()`, `goBackToPhone()`
  - `signOut()` → DB close, provider invalidation, clearPin, signOut (moved from AuthService)
  - `_startResendTimer()` internal timer management
- Moved from `lib/main.dart`: `_PinGate` logic (hasPin check, savePin, validatePin)
- Moved from `lib/screens/login_screen.dart`: phone→OTP state machine, timer, verificationId/resendToken

### Step 4 — Presentation Screens (5 files, pure presentation)

**Create `presentation/screens/auth_gate.dart`**
- `AuthGate` — `ConsumerStatefulWidget`
- Reads `authStateProvider` + `authProvider`
- Routes: no user → LoginScreen, user + not initialized → loading, user + complete → SubscriptionCheckScreen
- Logic from current `_AuthGateState` in `lib/main.dart:64-131`
- Calls `ref.read(authProvider.notifier).initForUser(uid)` on auth change

**Create `presentation/screens/login_screen.dart`**
- `LoginScreen` — `ConsumerStatelessWidget`
- Reads `authState.step` to show phone or OTP step
- Delegates `onPhoneSubmitted` → `ref.read(authProvider.notifier).sendOtp()`
- All phone-step UI stays identical (AnimatedLogo, WelcomeHeader, PhoneNumberInput, etc.)

**Create `presentation/screens/otp_screen.dart`**
- `OtpScreen` — `ConsumerStatelessWidget`
- Reads `authState.error`, `authState.loading`, `authState.resendSeconds`
- Delegates: `onCodeChanged` → `ref.read(authProvider.notifier).verifyOtp()`
- Delegates: `onResend` → `ref.read(authProvider.notifier).resendOtp()`
- OTP key reset: watch `authState.otpKey` to force rebuild via Key

**Create `presentation/screens/phone_number_screen.dart`**
- `PhoneNumberInput` — moved from `lib/screens/phone_number_screen.dart`
- Pure presentation, no changes needed beyond import paths

**Create `presentation/screens/pin_screen.dart`**
- `PinScreen` — `ConsumerStatelessWidget`
- Reads `authState.error`, `authState.loading`
- Delegates: `onPinCompleted` → `ref.read(authProvider.notifier).submitPin()`
- `PinMode` enum stays in this file
- `_PinDots` stays as private widget
- Back button → `ref.read(authProvider.notifier).goBackToPhone()`

### Step 5 — Login Widgets (4 files, move only)

Move from `lib/widgets/login/` to `presentation/widgets/login/`:
- `animated_logo.dart` — no changes
- `welcome_header.dart` — no changes
- `language_selector.dart` — no changes
- `login_footer.dart` — no changes

### Step 6 — Old File Cleanup (6 files)

**Rewrite `lib/services/auth_service.dart`** → re-export barrel:
```dart
export 'package:local_debt_management/features/authentication/data/providers/auth_providers.dart'
    show authServiceProvider, authStateProvider;
export 'package:local_debt_management/features/authentication/data/repositories/auth_repository_impl.dart';
```
This preserves all existing imports from `lib/Providers/`, `lib/widgets/drawer/`, etc.

**Rewrite `lib/services/pin_service.dart`** → re-export barrel:
```dart
export 'package:local_debt_management/features/authentication/data/repositories/pin_repository_impl.dart';
```
This preserves the import in `user_profile_header.dart`.

**Delete old screen files:**
- `lib/screens/login_screen.dart`
- `lib/screens/otp_screen.dart`
- `lib/screens/phone_number_screen.dart`
- `lib/screens/pin_screen.dart`

**Delete old login widgets:**
- `lib/widgets/login/animated_logo.dart`
- `lib/widgets/login/welcome_header.dart`
- `lib/widgets/login/language_selector.dart`
- `lib/widgets/login/login_footer.dart`

### Step 7 — Update Imports (1 file)

**`lib/main.dart`**
- Remove `AuthGate` + `_PinGate` classes (moved to `auth_gate.dart`)
- Remove imports: `screens/login_screen.dart`, `screens/pin_screen.dart`, `services/pin_service.dart`
- Add import: `features/authentication/presentation/screens/auth_gate.dart`
- `home: const AuthGate()` — now from the new location

## Files Affected Summary

| Action | Count | Files |
|--------|-------|-------|
| Create | 15 | domain (3) + data (3) + presentation (9) |
| Rewrite as re-export | 2 | auth_service.dart, pin_service.dart |
| Update imports | 1 | main.dart |
| Delete | 8 | 4 screens + 4 login widgets |

**Total: 15 new, 3 modified, 8 deleted**

## Verification
- `flutter analyze` must pass with 0 issues
- `flutter build apk --debug` must succeed
- Full auth flow test on device: phone → OTP → PIN setup → re-launch → PIN entry → home
