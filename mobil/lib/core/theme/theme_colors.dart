import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Colors that differ between the light and the dark theme.
extension AppThemeColors on BuildContext {
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;

  /// Dimmed text: weekday names, prayer names (like the website's muted color).
  Color get mutedText =>
      isLightTheme ? AppColors.lightMuted : AppColors.darkMuted;

  /// A slightly softer frame than the theme's outline, for the location
  /// buttons, the prayer-time tables and the month calendar.
  Color get softOutline =>
      Theme.of(this).colorScheme.outline.withValues(alpha: 0.55);

  /// The color of a chosen / "on" state: gray in the light theme, the brand
  /// green in the dark one.
  Color get accentFill =>
      isLightTheme ? AppColors.lightSurfaceStrong : const Color(0xFF396E0D);
}
