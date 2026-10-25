import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                user.fullName ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Center(child: Text(user.email)),
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
              leading: const Icon(Icons.mail_outline),
              title: const Text("Bog'lanish"),
              onTap: () => _showContact(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Dastur haqida'),
              onTap: () => _showAbout(context),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                "Akkauntni o'chirish",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  static const _supportEmail = 'support.praytime@gmail.com';

  static final _contactButtonStyle = TextButton.styleFrom(
    foregroundColor: const Color(0xFF4CAF17),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  );

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Akkauntni o'chirish"),
        content: const Text(
          "Akkauntingiz va unga bog'liq barcha ma'lumotlar (namoz belgilari, "
          "eslatma sozlamalari) butunlay o'chiriladi. Bu amalni qaytarib bo'lmaydi.",
        ),
        actions: [
          TextButton(
            style: _contactButtonStyle,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authProvider.notifier).deleteAccount();
    if (!context.mounted) return;
    if (ref.read(authProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akkauntni o'chirib bo'lmadi. Qayta urinib ko'ring."),
        ),
      );
      return;
    }
    context.go(RouteNames.login);
  }

  void _showContact(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Bog'lanish uchun:"),
        content: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SelectableText(
            _supportEmail,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          TextButton(
            style: _contactButtonStyle,
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: _supportEmail));
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Nusxalandi')));
              }
            },
            child: const Text('Nusxalash'),
          ),
          TextButton(
            style: _contactButtonStyle,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final textTheme = Theme.of(dialogContext).textTheme;
        final body = textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.45);

        Widget bullet(String text) => Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: body),
              Expanded(child: Text(text, style: body)),
            ],
          ),
        );

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pray Time - namozlaringiz sarhisobi',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ushbu ilova yordamida siz:', style: body),
                          bullet('kunlik namozlarni'),
                          bullet("yillik ro'zalarni"),
                          bullet('qazo namozlarni'),
                          bullet("qazo ro'zalarni"),
                          const SizedBox(height: 4),
                          Text('belgilab borishingiz mumkin.', style: body),
                          const SizedBox(height: 16),
                          Text('Bundan tashqari:', style: body),
                          bullet(
                            "Duolar bo'limidagi ko'plab kerakli duolarni o'rganishingiz",
                          ),
                          bullet(
                            "Qur'on bo'limidagi kitob, audio va tarjima sahifalaridan ham foydalanishingiz mumkin.",
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Ilova foydali bo'ladi degan umiddaman!",
                            style: body?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: _contactButtonStyle,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Yopish'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
