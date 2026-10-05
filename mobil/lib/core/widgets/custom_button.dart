import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.fontSize,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF396E0D),
            ),
          )
        : Text(label, style: fontSize == null ? null : TextStyle(fontSize: fontSize));

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: foregroundColor,
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: child,
    );
  }
}
