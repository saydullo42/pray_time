import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar.dart';

/// Hosts the bottom-navigation tabs (Home, Yillik tracking, Qur'an, Duo,
/// Profile) inside a single go_router StatefulShellRoute, so each tab keeps
/// its own navigation stack and scroll position when switching tabs.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
