import 'package:flutter/material.dart';

/// Tints a calendar day by how many of that day's prayers were marked done:
/// green for all 6, amber for 3-5, red for 0-2. Returns null (no tint) when
/// [count] is null, i.e. the day has no tracking data at all.
Color? colorForCompletionCount(int? count) {
  if (count == null) return null;
  if (count >= 6) return Colors.green.withValues(alpha: 0.45);
  if (count >= 3) return Colors.amber.withValues(alpha: 0.45);
  return Colors.red.withValues(alpha: 0.45);
}
