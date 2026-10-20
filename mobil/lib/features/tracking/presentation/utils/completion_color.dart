import 'package:flutter/material.dart';

/// Tints a calendar day by how many of that day's prayers were marked done:
/// green for all 6, amber for 3-5, red for 0-2 (the same colors as the website). Returns null (no tint) when
/// [count] is null, i.e. the day has no tracking data at all.
Color? colorForCompletionCount(int? count) {
  if (count == null) return null;
  if (count >= 6) return const Color.fromRGBO(46, 125, 50, 0.45);
  if (count >= 3) return const Color.fromRGBO(255, 193, 7, 0.4);
  return const Color.fromRGBO(198, 40, 40, 0.45);
}
