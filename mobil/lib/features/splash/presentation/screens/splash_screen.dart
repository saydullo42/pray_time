import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Decides where to route on cold start based on [authProvider]: to the
/// login screen if there's no session, otherwise straight to the home tab.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final state = await ref.read(authProvider.future);
    if (!mounted) return;
    if (state is AuthAuthenticated) {
      context.go(RouteNames.home);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque_outlined, size: 64),
            SizedBox(height: 16),
            Text(AppConstants.appName, style: TextStyle(fontSize: 22)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF396E0D)),
          ],
        ),
      ),
    );
  }
}
