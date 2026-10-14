import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobil/core/routing/route_names.dart';
import 'package:mobil/core/routing/startup_gate.dart';
import 'package:mobil/features/auth/data/models/user_model.dart';
import 'package:mobil/features/auth/presentation/providers/auth_provider.dart';

class _FakeAuth extends AuthNotifier {
  _FakeAuth(this.result);
  final Future<AuthState> Function() result;

  @override
  Future<AuthState> build() => result();
}

Future<void> _openApp(
  WidgetTester tester,
  Future<AuthState> Function() auth,
) async {
  final router = GoRouter(
    initialLocation: RouteNames.startup,
    routes: [
      GoRoute(path: RouteNames.startup, builder: (_, _) => const StartupGate()),
      GoRoute(path: RouteNames.home, builder: (_, _) => const Text('HOME')),
      GoRoute(path: RouteNames.login, builder: (_, _) => const Text('LOGIN')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authProvider.overrideWith(() => _FakeAuth(auth))],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a saved session opens the home screen at once', (tester) async {
    await _openApp(tester, () async => const AuthInitial());
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('a signed-in user opens the home screen', (tester) async {
    await _openApp(
      tester,
      () async =>
          const AuthAuthenticated(UserModel(id: '1', email: 'a@example.com')),
    );
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('no session opens the login screen', (tester) async {
    await _openApp(tester, () async => const AuthUnauthenticated());
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('a failure reading the session opens the login screen', (
    tester,
  ) async {
    await _openApp(tester, () async => throw StateError('storage unavailable'));
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('there is no artificial delay', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => _FakeAuth(() async => const AuthUnauthenticated()),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: RouteNames.startup,
            routes: [
              GoRoute(
                path: RouteNames.startup,
                builder: (_, _) => const StartupGate(),
              ),
              GoRoute(
                path: RouteNames.login,
                builder: (_, _) => const Text('LOGIN'),
              ),
            ],
          ),
        ),
      ),
    );
    // A few frames, far less than the old 4 second splash.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
