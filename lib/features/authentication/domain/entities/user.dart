/// AUTHENTICATION FEATURE — DOMAIN LAYER: ENTITIES
///
/// Represents an authenticated user in the system.
/// ---------------------------------------------------------------------------
library;

class User {
  final String uid;
  final String phoneNumber;
  final String displayName;

  const User({
    required this.uid,
    required this.phoneNumber,
    this.displayName = '',
  });

  User copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
  }) {
    return User(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
    );
  }
}
