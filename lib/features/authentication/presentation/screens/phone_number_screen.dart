/// AUTHENTICATION FEATURE — PRESENTATION LAYER: PHONE NUMBER INPUT
///
/// Pure presentation widget — keeps internal text field state.
/// No provider dependency; delegates via callback.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

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
  String? _error;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _controller.addListener(_validate);
  }

  @override
  void dispose() {
    _controller.removeListener(_validate);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _fullPhone => '+964${_controller.text.trim()}';

  bool get _isValid {
    final digits = _controller.text.trim();
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
    setState(() { _loading = true; _error = null; });
    widget.onPhoneSubmitted(_fullPhone);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final hasError = _error != null || (_touched && !_isValid);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? cs.error
                    : _isValid && _touched
                        ? cs.primary
                        : cs.outline.withValues(alpha: 0.3),
                width: hasError || (_isValid && _touched) ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    '+\u200B964',
                    style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    style: tt.bodyLarge?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: '7XX XXX XXXX',
                      hintStyle: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                        letterSpacing: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (_) {
                      if (_touched) setState(() {});
                    },
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                if (_isValid && _touched)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: cs.primary,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              _error ?? l10n.phoneInvalid,
              style: tt.bodySmall?.copyWith(color: cs.error),
            ),
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
                        Icon(Icons.sms_outlined, size: 20, color: Colors.white),
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
    );
  }
}
