/// AUTHENTICATION FEATURE — PRESENTATION LAYER: PHONE NUMBER INPUT
///
/// Pure presentation widget — keeps internal text field state.
/// No provider dependency; delegates via callback.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

/// Groups digits as the user types to match the `7XX XXX XXXX` hint mask.
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 11 ? digits.substring(0, 11) : digits;
    final grouped = _group(capped);
    if (grouped == newValue.text) return newValue;
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }

  static String _group(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    var i = 0;
    final len = digits.length;
    while (i < len) {
      if (buffer.isNotEmpty) buffer.write(' ');
      final remaining = len - i;
      final take = remaining == 4 ? 4 : (remaining >= 3 ? 3 : remaining);
      buffer.write(digits.substring(i, i + take));
      i += take;
    }
    return buffer.toString();
  }
}

class PhoneNumberInput extends StatefulWidget {
  final ValueChanged<String> onPhoneSubmitted;
  const PhoneNumberInput({super.key, required this.onPhoneSubmitted});

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  final _controller = TextEditingController(text: '7');
  final _focusNode = FocusNode();
  bool _loading = false;
  bool _focused = false;
  String? _error;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_validate);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_validate);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  String get _rawDigits => _controller.text.replaceAll(RegExp(r'\D'), '');

  String get _fullPhone => '+964$_rawDigits';

  bool get _isValid {
    final digits = _rawDigits;
    return digits.length >= 10 && digits.length <= 11;
  }

  void _validate() {
    if (_touched && mounted) setState(() {});
  }

  void _submit() {
    setState(() => _touched = true);
    if (!_isValid) {
      setState(() => _error = AppLocalizations.of(context)!.phoneInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    widget.onPhoneSubmitted(_fullPhone);
  }

  Widget _buildPhonePreview(
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final grouped = _rawDigits.isEmpty
        ? ''
        : _PhoneNumberFormatter._group(_rawDigits);
    final valid = _isValid;
    final tint = valid && _touched
        ? cs.primary
        : cs.onSurfaceVariant.withValues(alpha: 0.6);
    // LRM anchors the digits so they never reorder inside an RTL sentence.
    final destination = '\u200E+964 $grouped';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey('phones__${grouped}__$valid'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sms_outlined, size: 16, color: tint),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.verificationCodeTo(destination),
                style: tt.bodySmall?.copyWith(
                  color: tint,
                  fontWeight: valid ? FontWeight.w600 : FontWeight.w400,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final hasError = _error != null || (_touched && !_isValid);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: hasError
                      ? cs.error.withValues(alpha: 0.06)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasError
                        ? cs.error
                        : _focused
                        ? cs.secondary
                        : _isValid && _touched
                        ? cs.primary
                        : cs.outline.withValues(alpha: 0.3),
                    width: hasError || _focused || (_isValid && _touched)
                        ? 1.5
                        : 1.2,
                  ),
                  boxShadow: _focused
                      ? [
                          BoxShadow(
                            color: cs.secondary.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textAlign: TextAlign.center,
                  // Digits are inherently LTR — force it so an RTL
                  // (Arabic) locale never reorders the number.
                  textDirection: TextDirection.ltr,
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _PhoneNumberFormatter(),
                    LengthLimitingTextInputFormatter(14),
                  ],
                  style: tt.bodyLarge?.copyWith(
                    fontSize: 22,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    hintText: '7XX XXX XXXX',
                    hintStyle: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                      letterSpacing: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: 6),
                Text(
                  _error ?? l10n.phoneInvalid,
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
              ],
              if (_rawDigits.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildPhonePreview(l10n, cs, tt),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: cs.primary.withValues(alpha: 0.5),
                    elevation: 2,
                    shadowColor: cs.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sms_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.sendCode,
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
            ],
          ),
        ),
      ),
    );
  }
}
