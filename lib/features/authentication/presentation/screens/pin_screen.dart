/// AUTHENTICATION FEATURE — PRESENTATION LAYER: PIN SCREEN
///
/// Pure presentation — reads error/loading from provider.
/// Delegates pin submission to AuthNotifier.
/// Keeps internal obscureText toggle and pin dots.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

enum PinMode { setup, entry }

class PinScreen extends ConsumerStatefulWidget {
  final PinMode mode;

  const PinScreen({
    super.key,
    required this.mode,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameFocus = FocusNode();
  final _pinFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _isConfirmStep = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _pinFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool get _isSetup => widget.mode == PinMode.setup;

  void _submit() {
    if (_isSetup && !_isConfirmStep) {
      final pin = _pinController.text.trim();
      if (pin.length < 4) return;
      setState(() {
        _isConfirmStep = true;
        _confirmController.clear();
        _obscureText = true;
      });
      _confirmFocus.requestFocus();
      return;
    }

    final pin = _isSetup
        ? _confirmController.text.trim()
        : _pinController.text.trim();
    if (pin.length < 4) return;

    if (_isSetup && pin != _pinController.text.trim()) return;

    ref.read(authProvider.notifier).submitPin(pin);
  }

  bool get _canSubmit {
    if (_isSetup && !_isConfirmStep) {
      return _nameController.text.trim().isNotEmpty &&
          _pinController.text.length >= 4;
    }
    final len = (_isSetup && _isConfirmStep
            ? _confirmController
            : _pinController)
        .text
        .length;
    return len >= 4;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);

    final title = _isSetup
        ? (_isConfirmStep ? l10n.confirmPin : l10n.pinSetupTitle)
        : l10n.pinEntryTitle;
    final subtitle = _isSetup
        ? (_isConfirmStep ? l10n.pinSetupSubtitle : l10n.profileSetupSubtitle)
        : l10n.pinEntrySubtitle;

    final currentController =
        _isSetup && _isConfirmStep ? _confirmController : _pinController;
    final currentFocus =
        _isSetup && _isConfirmStep ? _confirmFocus : _pinFocus;
    final pinLength = currentController.text.length;

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
                      if (_isConfirmStep)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => setState(() {
                              _isConfirmStep = false;
                              _confirmController.clear();
                            }),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: cs.onSurface,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              cs.primary,
                              cs.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isSetup
                              ? Icons.shield_rounded
                              : Icons.lock_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        title,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),
                      if (_isSetup && !_isConfirmStep) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: TextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            textCapitalization: TextCapitalization.words,
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: l10n.nameHint,
                              hintStyle: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                size: 20,
                                color: cs.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color:
                                      cs.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: cs.primary,
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: cs.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                            ),
                            onChanged: (v) {
                              ref
                                  .read(authProvider.notifier)
                                  .setUserName(v.trim());
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _PinDots(
                        length: pinLength,
                        maxLength: 6,
                        hasError: authState.error != null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: TextField(
                          controller: currentController,
                          focusNode: currentFocus,
                          obscureText: _obscureText,
                          obscuringCharacter: '\u2022',
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: tt.headlineSmall?.copyWith(
                            letterSpacing: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: l10n.pinHint,
                            hintStyle: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                            suffixIcon: currentController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () => setState(
                                        () => _obscureText = !_obscureText),
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      size: 20,
                                      color: cs.onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                    ),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: cs.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: cs.primary,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                cs.surfaceContainerHighest.withValues(alpha: 0.4),
                          ),
                          onChanged: (v) => setState(() {}),
                        ),
                      ),
                      if (authState.error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.errorContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 16, color: cs.error),
                              const SizedBox(width: 6),
                              Text(
                                authState.error!,
                                style:
                                    tt.bodySmall?.copyWith(color: cs.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (authState.loading)
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: Card(
                            elevation: 0,
                            color: cs.primaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _canSubmit ? _submit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  cs.primary.withValues(alpha: 0.3),
                              disabledForegroundColor:
                                  Colors.white.withValues(alpha: 0.5),
                              elevation: _canSubmit ? 2 : 0,
                              shadowColor: cs.primary.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isSetup && !_isConfirmStep
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isSetup
                                      ? (_isConfirmStep
                                          ? l10n.confirmPin
                                          : l10n.createPin)
                                      : l10n.enterPin,
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _PinDots extends StatelessWidget {
  final int length;
  final int maxLength;
  final bool hasError;

  const _PinDots({
    required this.length,
    required this.maxLength,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (i) {
        final filled = i < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? hasError
                    ? cs.error
                    : cs.primary
                : cs.outline.withValues(alpha: 0.2),
            border: Border.all(
              color: filled
                  ? hasError
                      ? cs.error
                      : cs.primary
                  : cs.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: (hasError ? cs.error : cs.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
