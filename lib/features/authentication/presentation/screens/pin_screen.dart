/// AUTHENTICATION FEATURE — PRESENTATION LAYER: PIN SCREEN
///
/// Pure presentation — reads error/loading from provider.
/// Delegates pin submission to AuthNotifier.
/// PIN digits are entered through a custom in-app keypad, so no system
/// keyboard pops up during PIN steps (the setup name field still uses one).
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin/pin_dots.dart';
import '../widgets/pin/pin_error_banner.dart';
import '../widgets/pin/pin_keypad.dart';
import '../widgets/pin/pin_name_field.dart';
import '../widgets/pin/pin_submit_key.dart';

enum PinMode { setup, entry }

class PinScreen extends ConsumerStatefulWidget {
  final PinMode mode;

  const PinScreen({super.key, required this.mode});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _isConfirmStep = false;
  bool _mismatchError = false;

  bool get _isSetup => widget.mode == PinMode.setup;

  TextEditingController get _currentController =>
      _isSetup && _isConfirmStep ? _confirmController : _pinController;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // INPUT — driven by the in-app keypad
  // ---------------------------------------------------------------------------

  void _onDigit(String d) {
    final c = _currentController;
    if (c.text.length >= 6) return;
    if (ref.read(authProvider).error != null) {
      ref.read(authProvider.notifier).resetError();
    }
    setState(() {
      _mismatchError = false;
      c.text = '${c.text}$d';
      c.selection = TextSelection.collapsed(offset: c.text.length);
    });
    if (c.text.length == 6) _submit();
  }

  void _onBackspace() {
    final c = _currentController;
    if (c.text.isEmpty) return;
    setState(() {
      _mismatchError = false;
      c.text = c.text.substring(0, c.text.length - 1);
      c.selection = TextSelection.collapsed(offset: c.text.length);
    });
  }

  void _onClear() {
    setState(() {
      _mismatchError = false;
      _currentController.clear();
    });
  }

  // ---------------------------------------------------------------------------
  // SUBMISSION — same flow the old screen used
  // ---------------------------------------------------------------------------

  void _submit() {
    if (_isSetup && !_isConfirmStep) {
      if (_pinController.text.trim().length < 4) return;
      setState(() {
        _isConfirmStep = true;
        _mismatchError = false;
        _confirmController.clear();
      });
      return;
    }

    final pin = _currentController.text.trim();
    if (pin.length < 4) return;

    if (_isSetup && pin != _pinController.text.trim()) {
      setState(() => _mismatchError = true);
      return;
    }

    ref.read(authProvider.notifier).submitPin(pin);
  }

  bool get _canSubmit {
    if (_isSetup && !_isConfirmStep) {
      return _nameController.text.trim().isNotEmpty &&
          _pinController.text.length >= 4;
    }
    final len = _currentController.text.length;
    if (len < 4) return false;
    if (_isSetup) return _currentController.text == _pinController.text.trim();
    return true;
  }

  void _goBackToCreate() {
    setState(() {
      _isConfirmStep = false;
      _mismatchError = false;
      _confirmController.clear();
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    final isNameStep = _isSetup && !_isConfirmStep;
    final title = _isSetup
        ? (_isConfirmStep ? l10n.confirmPin : l10n.pinSetupTitle)
        : l10n.pinEntryTitle;
    final subtitle = _isSetup
        ? (_isConfirmStep ? l10n.pinSetupSubtitle : l10n.profileSetupSubtitle)
        : l10n.pinEntrySubtitle;

    final displayError = _mismatchError
        ? l10n.pinMismatch
        : (authState.error == 'incorrect_pin'
              ? l10n.incorrectPin
              : authState.error);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [cs.primary.withValues(alpha: 0.06), cs.surface],
          // ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CallbackShortcuts(
                bindings: isNameStep ? const {} : _keypadShortcuts,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                              onPressed: _goBackToCreate,
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: cs.onSurface,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 8),
                        const SizedBox(height: 12),
                        //PinLogo(isSetup: _isSetup),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        if (isNameStep) ...[
                          PinNameField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hint: l10n.nameHint,
                            onChanged: (v) {
                              ref
                                  .read(authProvider.notifier)
                                  .setUserName(v.trim());
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                        PinDots(
                          value: _currentController.text,
                          maxLength: 6,
                          hasError: displayError != null,
                        ),
                        const SizedBox(height: 20),
                        if (displayError != null) ...[
                          PinErrorBanner(message: displayError),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 24),
                        PinKeypad(
                          onDigit: _onDigit,
                          onBackspace: _onBackspace,
                          onClear: _onClear,
                          bottomLeft: PinSubmitKey(
                            loading: authState.loading,
                            enabled: _canSubmit,
                            isNext: isNameStep,
                            onPressed: _submit,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Physical keyboard support for the PIN steps: digits, backspace, enter.
  Map<ShortcutActivator, VoidCallback> get _keypadShortcuts {
    return <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.digit1): () => _onDigit('1'),
      const SingleActivator(LogicalKeyboardKey.digit2): () => _onDigit('2'),
      const SingleActivator(LogicalKeyboardKey.digit3): () => _onDigit('3'),
      const SingleActivator(LogicalKeyboardKey.digit4): () => _onDigit('4'),
      const SingleActivator(LogicalKeyboardKey.digit5): () => _onDigit('5'),
      const SingleActivator(LogicalKeyboardKey.digit6): () => _onDigit('6'),
      const SingleActivator(LogicalKeyboardKey.digit7): () => _onDigit('7'),
      const SingleActivator(LogicalKeyboardKey.digit8): () => _onDigit('8'),
      const SingleActivator(LogicalKeyboardKey.digit9): () => _onDigit('9'),
      const SingleActivator(LogicalKeyboardKey.digit0): () => _onDigit('0'),
      const SingleActivator(LogicalKeyboardKey.numpad1): () => _onDigit('1'),
      const SingleActivator(LogicalKeyboardKey.numpad2): () => _onDigit('2'),
      const SingleActivator(LogicalKeyboardKey.numpad3): () => _onDigit('3'),
      const SingleActivator(LogicalKeyboardKey.numpad4): () => _onDigit('4'),
      const SingleActivator(LogicalKeyboardKey.numpad5): () => _onDigit('5'),
      const SingleActivator(LogicalKeyboardKey.numpad6): () => _onDigit('6'),
      const SingleActivator(LogicalKeyboardKey.numpad7): () => _onDigit('7'),
      const SingleActivator(LogicalKeyboardKey.numpad8): () => _onDigit('8'),
      const SingleActivator(LogicalKeyboardKey.numpad9): () => _onDigit('9'),
      const SingleActivator(LogicalKeyboardKey.numpad0): () => _onDigit('0'),
      const SingleActivator(LogicalKeyboardKey.backspace): _onBackspace,
      const SingleActivator(LogicalKeyboardKey.enter): () => _submit(),
    };
  }
}
