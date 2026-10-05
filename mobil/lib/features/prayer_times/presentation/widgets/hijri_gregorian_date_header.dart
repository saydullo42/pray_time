import 'package:flutter/material.dart';
import '../../../../core/utils/date_converter.dart';

class HijriGregorianDateHeader extends StatelessWidget {
  const HijriGregorianDateHeader({super.key, this.date, this.onHijriTap});

  final DateTime? date;

  /// Called when the Hijri date text is tapped, e.g. to open a yearly Hijri
  /// calendar. If null, the Hijri date isn't tappable.
  final VoidCallback? onHijriTap;

  @override
  Widget build(BuildContext context) {
    final d = date ?? DateTime.now();
    final hijriText = Text(
      DateConverter.formatHijri(d),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4CAF17),
          ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        onHijriTap == null ? hijriText : GestureDetector(onTap: onHijriTap, child: hijriText),
        Text(
          DateConverter.formatGregorian(d),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
