import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      height: 64,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Asosiy'),
        const NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Yillik'),
        const NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Qur\'on'),
        NavigationDestination(
          icon: _MonoEmojiIcon(color: colorScheme.onSurfaceVariant),
          selectedIcon: _MonoEmojiIcon(color: colorScheme.onSecondaryContainer),
          label: 'Duo',
        ),
        const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}

/// Renders the open-hands emoji as a flat, single-color icon (no emoji
/// colors) so it matches the outline style of the other nav bar icons.
class _MonoEmojiIcon extends StatelessWidget {
  const _MonoEmojiIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: const Text('🤲', style: TextStyle(fontSize: 22)),
    );
  }
}
