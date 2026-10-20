import 'package:flutter/material.dart';

const _danger = Color(0xFFC62828);
const _green = Color(0xFF2E7D32);

/// The "Hammasini o'chirish" / "Hammasini belgilash" pair, styled like on the
/// website: two outlined pills, red and green, with a transparent background.
class MarkAllButtons extends StatelessWidget {
  const MarkAllButtons({
    super.key,
    required this.onClearAll,
    required this.onMarkAll,
    this.isBusy = false,
  });

  final VoidCallback onClearAll;
  final VoidCallback onMarkAll;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PillButton(
            label: 'Hammasini o\'chirish',
            color: _danger,
            isBusy: isBusy,
            onPressed: onClearAll,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillButton(
            label: 'Hammasini belgilash',
            color: _green,
            bold: true,
            isBusy: isBusy,
            onPressed: onMarkAll,
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.color,
    required this.isBusy,
    required this.onPressed,
    this.bold = false,
  });

  final String label;
  final Color color;
  final bool isBusy;
  final bool bold;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isBusy ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      child: isBusy
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
    );
  }
}
