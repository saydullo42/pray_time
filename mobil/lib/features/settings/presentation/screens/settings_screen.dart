import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final method = ref.watch(calculationMethodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Mavzu'),
            subtitle: Text(switch (themeMode) {
              ThemeMode.light => 'Yorug\'',
              ThemeMode.dark => 'Qorong\'i',
              ThemeMode.system => 'Tizim bo\'yicha',
            }),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (mode) {
                if (mode != null) ref.read(themeModeProvider.notifier).setThemeMode(mode);
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Tizim bo\'yicha')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Yorug\'')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Qorong\'i')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Hisoblash usuli'),
            subtitle: Text(method.label),
            onTap: () {}, // TODO: open a picker over CalculationMethod.values
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Eslatma sozlamalari'),
            onTap: () => context.push(RouteNames.notificationSettings),
          ),
        ],
      ),
    );
  }
}
