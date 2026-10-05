import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(user.fullName ?? '', style: Theme.of(context).textTheme.titleLarge),
            ),
            Center(child: Text(user.phoneNumber)),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Profilni tahrirlash'),
              onTap: () => context.push(RouteNames.editProfile),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Eslatma sozlamalari'),
              onTap: () => context.push(RouteNames.notificationSettings),
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Tungi rejim'),
              value: themeMode == ThemeMode.dark,
              activeThumbColor: const Color(0xFF396E0D),
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Chiqish', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
