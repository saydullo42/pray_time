import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'route_names.dart';

/// The app's first route. It shows nothing (the native splash screen is still
/// on screen until the first frame, and this page has the same background) and
/// forwards at once: to the home tab when a session is saved, otherwise to the
/// login screen.
class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key});

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    AuthState? state;
    try {
      state = await ref.read(authProvider.future);
    } catch (_) {
      // Reading the saved session failed: treat it as signed out.
    }
    if (!mounted) return;
    // AuthInitial = a saved session from an earlier launch; it is checked (and
    // refreshed if needed) by the first API call.
    if (state is AuthAuthenticated || state is AuthInitial) {
      context.go(RouteNames.home);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
