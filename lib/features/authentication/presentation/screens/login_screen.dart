/// AUTHENTICATION FEATURE — PRESENTATION LAYER: LOGIN SCREEN
///
/// Pure presentation — reads auth state and delegates to AuthNotifier.
/// Shows phone input or OTP step based on current auth step.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/login/animated_logo.dart';
import '../widgets/login/welcome_header.dart';
import '../widgets/login/language_selector.dart';
import '../widgets/login/login_footer.dart';
import 'phone_number_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);

    if (authState.isOtpStep) {
      return OtpScreen(
        key: ValueKey('otp_${authState.otpKey}'),
        phoneNumber: authState.phoneNumber,
        error: authState.error,
        loading: authState.loading,
        onCodeChanged: (code) => notifier.verifyOtp(code),
        onResend: authState.resendSeconds <= 0 ? () => notifier.resendOtp() : null,
        resendSeconds: authState.resendSeconds,
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      const AnimatedLogo(),
                      const SizedBox(height: 32),
                      const WelcomeHeader(),
                      const SizedBox(height: 48),
                      if (authState.error != null) ...[
                        _ErrorBanner(message: authState.error!),
                        const SizedBox(height: 16),
                      ],
                      PhoneNumberInput(
                        onPhoneSubmitted: (phone) => notifier.sendOtp(phone),
                      ),
                      const SizedBox(height: 24),
                      const LanguageSelector(),
                      const SizedBox(height: 48),
                      const LoginFooter(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
