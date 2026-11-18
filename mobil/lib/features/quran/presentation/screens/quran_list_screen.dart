import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_colors.dart';

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(64),
      side: BorderSide.none,
      // Light theme: like the cards of the Duolar section; dark: dark green.
      foregroundColor: context.isLightTheme
          ? AppColors.lightOnSurface
          : Colors.white,
      backgroundColor: context.isLightTheme
          ? AppColors.lightSurface
          : const Color(0xFF004225),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Qur\'oni Karim')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
        child: Column(
          children: [
            OutlinedButton(
              style: buttonStyle,
              onPressed: () => context.push(RouteNames.quranBookList),
              child: const Text('Qur\'on kitob'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: buttonStyle,
              onPressed: () => context.push(RouteNames.quranReciterList),
              child: const Text('Qur\'on audio'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: buttonStyle,
              onPressed: () => context.push(RouteNames.quranTranslationList),
              child: const Text('Qur\'on tarjimasi'),
            ),
          ],
        ),
      ),
    );
  }
}
