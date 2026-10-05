import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formats raw digits (optionally already containing "998"/spaces/"+") into
/// "+998 90 381 99 04". Shared by the input formatter and the custom
/// [NumericKeypad] so both produce identical output.
String formatUzPhoneNumber(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('998')) {
    digits = digits.substring(3);
  }
  if (digits.length > 9) {
    digits = digits.substring(0, 9);
  }

  final buffer = StringBuffer('+998');
  void writeGroup(int start, int end) {
    if (digits.length > start) {
      buffer.write(' ');
      buffer.write(digits.substring(start, digits.length.clamp(start, end)));
    }
  }

  writeGroup(0, 2);
  writeGroup(2, 5);
  writeGroup(5, 7);
  writeGroup(7, 9);
  return buffer.toString();
}

/// Extracts just the 9 subscriber digits (without the "998" prefix) from a
/// formatted or partially-formatted phone string.
String extractUzPhoneDigits(String formatted) {
  var digits = formatted.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('998')) {
    digits = digits.substring(3);
  }
  return digits;
}

class _UzPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatUzPhoneNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Phone input pre-filled with the Uzbekistan country code, used on the
/// login/register screen before requesting an SMS OTP.
///
/// The field is read-only: digits are entered via [NumericKeypad] instead of
/// the system keyboard, so the phone number can only ever contain digits,
/// backspace and submit — no extra symbols some system/third-party
/// keyboards insert for TextInputType.phone/number.
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({super.key, required this.controller, this.validator});

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      showCursor: true,
      validator: validator,
      inputFormatters: [_UzPhoneNumberFormatter()],
      decoration: InputDecoration(
        labelText: 'Telefon raqam',
        hintText: '+998 90 123 45 67',
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// A digits-only (0-9), backspace and submit on-screen keypad, used instead
/// of the system keyboard on the phone number entry screen.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  Widget _key(BuildContext context, Widget child, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 56,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _digitKey(BuildContext context, String digit) {
    return _key(
      context,
      Text(digit, style: Theme.of(context).textTheme.headlineSmall),
      () => onDigit(digit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [_digitKey(context, '1'), _digitKey(context, '2'), _digitKey(context, '3')]),
        Row(children: [_digitKey(context, '4'), _digitKey(context, '5'), _digitKey(context, '6')]),
        Row(children: [_digitKey(context, '7'), _digitKey(context, '8'), _digitKey(context, '9')]),
        Row(
          children: [
            _key(
              context,
              const Icon(Icons.check_circle, color: Color(0xFF396E0D), size: 28),
              onSubmit,
            ),
            _digitKey(context, '0'),
            _key(context, const Icon(Icons.backspace_outlined), onBackspace),
          ],
        ),
      ],
    );
  }
}
