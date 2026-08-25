/// AUTHENTICATION FEATURE — PRESENTATION LAYER: OTP SCREEN
///
/// Keeps internal input state (6 digit controllers + focus nodes).
/// Reads error/loading/resend state from provider.
/// Delegates verify/resend actions to AuthNotifier.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/otp/otp_input_row.dart';
import '../widgets/otp/otp_verify_button.dart';
import '../widgets/otp/otp_resend_section.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? error;
  final bool loading;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback? onResend;
  final int resendSeconds;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.error,
    this.loading = false,
    required this.onCodeChanged,
    this.onResend,
    this.resendSeconds = 0,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _autoVerifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index) {
    final text = _controllers[index].text;
    if (text.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == 6) {
      setState(() => _autoVerifying = true);
      widget.onCodeChanged(_code);
    }
  }

  void _onVerify() {
    setState(() => _autoVerifying = true);
    widget.onCodeChanged(_code);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final masked = widget.phoneNumber.replaceRange(
      widget.phoneNumber.length - 4,
      widget.phoneNumber.length,
      '****',
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.06),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () =>
                              ref.read(authProvider.notifier).goBackToPhone(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _OtpHeaderIcon(cs: cs),
                      const SizedBox(height: 28),
                      Text(
                        l10n.verifyCode,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.codeSentTo(masked),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      OtpInputRow(
                        controllers: _controllers,
                        focusNodes: _focusNodes,
                        onChanged: _onDigitChanged,
                        error: widget.error,
                      ),
                      const SizedBox(height: 28),
                      OtpVerifyButton(
                        loading: _autoVerifying || widget.loading,
                        canVerify: _code.length == 6,
                        onVerify: _onVerify,
                      ),
                      const SizedBox(height: 20),
                      OtpResendSection(
                        resendSeconds: widget.resendSeconds,
                        onResend: widget.onResend,
                      ),
                      const SizedBox(height: 48),
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

class _OtpHeaderIcon extends StatelessWidget {
  final ColorScheme cs;
  const _OtpHeaderIcon({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(Icons.sms_rounded, size: 34, color: Colors.white),
    );
  }
}
