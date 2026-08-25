/// AUTHENTICATION FEATURE — DATA LAYER: PROVIDERS
///
/// Riverpod providers for the authentication feature.
/// Wires up repositories and exposes the auth state stream.
///
/// ARCHITECTURE RULE: This is the composition root for auth dependencies.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/pin_repository.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/pin_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final pinRepositoryProvider = Provider<PinRepository>(
  (ref) => PinRepositoryImpl(),
);

final authUserProvider = StreamProvider.autoDispose((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});
