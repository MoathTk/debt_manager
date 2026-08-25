/// AUTHENTICATION FEATURE — PRESENTATION LAYER: STATE
///
/// Immutable state class for the authentication feature.
/// Managed by [AuthNotifier] via Riverpod's StateNotifier.
///
/// Flow: phone → otp → (pinSetup | pinEntry) → complete
/// ---------------------------------------------------------------------------
library;

enum AuthStep { phone, otp, pinSetup, pinEntry, complete }

class AuthState {
  final AuthStep step;
  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final bool loading;
  final String? error;
  final int resendSeconds;
  final bool hasPin;
  final String? userId;
  final String? userName;
  final String? userPhone;
  final int otpKey;

  const AuthState({
    this.step = AuthStep.phone,
    this.phoneNumber = '',
    this.verificationId,
    this.resendToken,
    this.loading = false,
    this.error,
    this.resendSeconds = 0,
    this.hasPin = false,
    this.userId,
    this.userName,
    this.userPhone,
    this.otpKey = 0,
  });

  AuthState copyWith({
    AuthStep? step,
    String? phoneNumber,
    String? verificationId,
    bool clearVerificationId = false,
    int? resendToken,
    bool clearResendToken = false,
    bool? loading,
    bool clearError = false,
    String? error,
    int? resendSeconds,
    bool? hasPin,
    String? userId,
    String? userName,
    String? userPhone,
    int? otpKey,
  }) {
    return AuthState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: clearVerificationId
          ? null
          : (verificationId ?? this.verificationId),
      resendToken: clearResendToken
          ? null
          : (resendToken ?? this.resendToken),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      resendSeconds: resendSeconds ?? this.resendSeconds,
      hasPin: hasPin ?? this.hasPin,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      otpKey: otpKey ?? this.otpKey,
    );
  }

  bool get isPhoneStep => step == AuthStep.phone;
  bool get isOtpStep => step == AuthStep.otp;
  bool get isPinSetupStep => step == AuthStep.pinSetup;
  bool get isPinEntryStep => step == AuthStep.pinEntry;
  bool get isComplete => step == AuthStep.complete;
}
