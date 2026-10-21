import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    // Like the website: the selected item is green (no pill behind it), the
    // others are muted; the same outline icon is used for both states.
    final selected = theme.brightness == Brightness.dark
        ? const Color(0xFF4CAF17)
        : const Color(0xFF2E7D32);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? selected : muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? selected : muted,
          ),
        ),
      ),
      child: NavigationBar(
        height: 64,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Asosiy',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Yillik',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Qur\'on',
          ),
          NavigationDestination(
            icon: _MonoEmojiIcon(color: muted),
            selectedIcon: _MonoEmojiIcon(color: selected),
            label: 'Duo',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
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
