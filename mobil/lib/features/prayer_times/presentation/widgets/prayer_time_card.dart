import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    super.key,
    required this.name,
    required this.time,
    required this.isNext,
    this.isCustom = false,
  });

  final String name;
  final DateTime time;
  final bool isNext;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: isNext ? scheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(
          _iconFor(name),
          color: isNext ? scheme.onPrimaryContainer : scheme.primary,
        ),
        title: Text(name),
        subtitle: isCustom ? const Text('Qo\'lda kiritilgan') : null,
        trailing: Text(
          DateFormat.Hm().format(time),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'Bomdod':
        return Icons.nights_stay_outlined;
      case 'Peshin':
        return Icons.wb_sunny_outlined;
      case 'Asr':
        return Icons.wb_twighlight;
      case 'Shom':
        return Icons.wb_shade_outlined;
      case 'Xufton':
        return Icons.dark_mode_outlined;
      default:
        return Icons.access_time;
    }
  }
}
