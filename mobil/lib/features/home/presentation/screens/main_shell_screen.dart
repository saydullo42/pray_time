import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../../../notifications/presentation/providers/reminder_sync_provider.dart';
import '../../../prayer_times/presentation/providers/region_selection_provider.dart';
import '../widgets/bottom_nav_bar.dart';

/// Hosts the bottom-navigation tabs (Home, Yillik tracking, Qur'an, Duo,
/// Profile) inside a single go_router StatefulShellRoute, so each tab keeps
/// its own navigation stack and scroll position when switching tabs.
///
/// It is also where prayer reminders are kept up to date: they are
/// rescheduled when the signed-in app opens, comes back to the foreground or
/// the region changes (see [ReminderSync]).
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncReminders();
      _askForReminderPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncReminders();
  }

  void _syncReminders() => ref.read(reminderSyncProvider).sync();

  /// Asked on every open until reminders are allowed. When Android no longer
  /// shows its own dialog, offer to open the app's settings instead.
  Future<void> _askForReminderPermission() async {
    final needsSettings = await ref
        .read(reminderSyncProvider)
        .requestPermissionsIfNeeded();
    if (!needsSettings || !mounted) return;

    const green = Color(0xFF4CAF17);
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        // One line: 18 sp, shrunk slightly only if a narrow screen needs it.
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "Bildirishnomalar o'chirilgan!",
            style: TextStyle(fontSize: 18),
            maxLines: 1,
          ),
        ),
        content: const Text(
          "Namoz vaqtlarini oldindan eslatish uchun bildirishnomalarga ruxsat bering",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: green,
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keyinroq'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: green,
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sozlamalar'),
          ),
        ],
      ),
    );
    if (openSettings == true) {
      await ref.read(localNotificationServiceProvider).openAppSettingsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(regionSelectionProvider, (previous, next) => _syncReminders());

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}
