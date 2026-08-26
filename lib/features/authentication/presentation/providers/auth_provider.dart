/// AUTHENTICATION FEATURE — PRESENTATION LAYER: PROVIDER
///
/// Manages the full authentication lifecycle:
/// phone input → OTP verification → PIN setup/entry → complete.
///
/// Consolidates logic from the former LoginScreen, _PinGate, and AuthService.
/// ---------------------------------------------------------------------------
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/services/clock_integrity_service.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/check_has_pin.dart';
import '../../domain/usecases/set_up_pin.dart';
import '../../domain/usecases/validate_pin.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../data/providers/auth_providers.dart';
import 'auth_state.dart';

final authProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, AuthState>(
  (ref) {
    final authRepo = ref.read(authRepositoryProvider);
    final pinRepo = ref.read(pinRepositoryProvider);
    return AuthNotifier(
      sendOtp: SendOtp(authRepo),
      verifyOtp: VerifyOtp(authRepo),
      checkHasPin: CheckHasPin(pinRepo),
      setUpPin: SetUpPin(pinRepo),
      validatePin: ValidatePin(pinRepo),
      getUserProfile: GetUserProfile(pinRepo),
      clearPin: pinRepo.clearPin,
      signOutRepo: authRepo.signOut,
      ref: ref,
    );
  },
);

class AuthNotifier extends StateNotifier<AuthState> {
  final SendOtp _sendOtp;
  final VerifyOtp _verifyOtp;
  final CheckHasPin _checkHasPin;
  final SetUpPin _setUpPin;
  final ValidatePin _validatePin;
  final GetUserProfile _getUserProfile;
  final Future<void> Function(String uid) _clearPin;
  final Future<void> Function() _signOutRepo;
  final Ref _ref;

  Timer? _resendTimer;
  String? _pendingVerificationId;
  int? _pendingResendToken;

  AuthNotifier({
    required SendOtp sendOtp,
    required VerifyOtp verifyOtp,
    required CheckHasPin checkHasPin,
    required SetUpPin setUpPin,
    required ValidatePin validatePin,
    required GetUserProfile getUserProfile,
    required Future<void> Function(String uid) clearPin,
    required Future<void> Function() signOutRepo,
    required Ref ref,
  })  : _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        _checkHasPin = checkHasPin,
        _setUpPin = setUpPin,
        _validatePin = validatePin,
        _getUserProfile = getUserProfile,
        _clearPin = clearPin,
        _signOutRepo = signOutRepo,
        _ref = ref,
        super(const AuthState());

  // ---------------------------------------------------------------------------
  // INIT — called by AuthGate when a user signs in
  // ---------------------------------------------------------------------------

  Future<void> initForUser(String uid) async {
    state = state.copyWith(
      userId: uid,
      loading: true,
      clearError: true,
    );

    try {
      final hasPin = await _checkHasPin(uid);
      final profile = await _getUserProfile(uid);

      if (!mounted) return;

      state = state.copyWith(
        hasPin: hasPin,
        userName: profile?['name'] ?? '',
        userPhone: profile?['phone'] ?? '',
        loading: false,
        step: hasPin ? AuthStep.pinEntry : AuthStep.pinSetup,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        step: AuthStep.pinSetup,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // OTP FLOW
  // ---------------------------------------------------------------------------

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(
      phoneNumber: phone,
      loading: true,
      clearError: true,
    );

    await _sendOtp(
      phoneNumber: phone,
      resendToken: _pendingResendToken,
      codeSent: (vid, token) {
        if (!mounted) return;
        _pendingVerificationId = vid;
        _pendingResendToken = token;
        state = state.copyWith(
          verificationId: vid,
          resendToken: token,
          loading: false,
          step: AuthStep.otp,
        );
        _startResendTimer();
      },
      verificationFailed: (msg) {
        if (!mounted) return;
        state = state.copyWith(
          loading: false,
          error: msg,
        );
      },
      autoVerify: (_) {},
      timeout: (vid) {
        _pendingVerificationId = vid;
      },
    );
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _resendSeconds--;
      state = state.copyWith(resendSeconds: _resendSeconds);
      if (_resendSeconds <= 0) t.cancel();
    });
  }

  int _resendSeconds = 60;

  Future<void> verifyOtp(String code) async {
    if (_pendingVerificationId == null) return;

    state = state.copyWith(loading: true, clearError: true);

    try {
      await _verifyOtp(
        verificationId: _pendingVerificationId!,
        smsCode: code,
      );
      // Auth state stream will trigger AuthGate rebuild
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        error: 'invalid_otp',
        otpKey: state.otpKey + 1,
      );
    }
  }

  void resendOtp() {
    if (_pendingResendToken != null) {
      sendOtp(state.phoneNumber);
    }
  }

  // ---------------------------------------------------------------------------
  // PIN FLOW
  // ---------------------------------------------------------------------------

  Future<void> submitPin(String pin) async {
    final uid = state.userId;
    if (uid == null) return;

    state = state.copyWith(loading: true, clearError: true);

    try {
      if (state.isPinSetupStep) {
        await _setUpPin(
          uid: uid,
          pin: pin,
          name: state.userName ?? '',
          phone: state.isPinSetupStep ? state.phoneNumber : (state.userPhone ?? ''),
        );
        if (!mounted) return;
        state = state.copyWith(
          loading: false,
          hasPin: true,
          step: AuthStep.complete,
        );
      } else {
        final valid = await _validatePin(uid: uid, pin: pin);
        if (!mounted) return;

        if (valid) {
          state = state.copyWith(
            loading: false,
            step: AuthStep.complete,
          );
        } else {
          state = state.copyWith(
            loading: false,
            error: 'incorrect_pin',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void goBackToPhone() {
    _resendTimer?.cancel();
    _pendingVerificationId = null;
    _pendingResendToken = null;
    state = const AuthState();
  }

  void resetError() {
    state = state.copyWith(clearError: true);
  }

  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }

  // ---------------------------------------------------------------------------
  // SIGN OUT
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    final uid = state.userId;
    await DatabaseHelper.instance.close();
    await ClockIntegrityService.clear();
    if (uid != null) await _clearPin(uid);

    _ref.invalidate(customersProvider);
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(pendingRemindersProvider);
    _ref.invalidate(allRemindersProvider);
    _ref.invalidate(dueTodayProvider);
    _ref.invalidate(dashboardStatsProvider);
    _ref.invalidate(syncProvider);
    _ref.invalidate(subscriptionProvider);

    await _signOutRepo();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
