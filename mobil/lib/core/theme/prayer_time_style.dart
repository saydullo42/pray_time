import 'package:flutter/material.dart';

/// The prayer-time digits (05:30), set in Geist, the website's font, at
/// font-medium (500) like on the website. Geist is a variable font, so the
/// weight goes in through its `wght` axis.
TextStyle prayerTimeStyle(BuildContext context) => TextStyle(
  fontFamily: 'Geist',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  fontVariations: const [FontVariation('wght', 500)],
  color: Theme.of(context).colorScheme.onSurface,
);
