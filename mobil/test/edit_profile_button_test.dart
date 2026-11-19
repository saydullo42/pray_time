import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/core/theme/app_theme.dart';
import 'package:mobil/features/auth/data/models/user_model.dart';
import 'package:mobil/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobil/features/profile/presentation/screens/edit_profile_screen.dart';

class _FakeProfile extends ProfileNotifier {
  @override
  Future<UserModel> build() async =>
      const UserModel(id: '1', email: 'a@example.com', fullName: 'Ali');
}

Future<ButtonStyle?> _style(WidgetTester tester, ThemeMode mode) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [profileProvider.overrideWith(_FakeProfile.new)],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: const EditProfileScreen(),
      ),
    ),
  );
  await tester.pump();
  return tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style;
}

void main() {
  testWidgets('dark theme: Saqlash has green text on a dark fill', (
    tester,
  ) async {
    final style = await _style(tester, ThemeMode.dark);
    expect(style?.foregroundColor?.resolve({}), const Color(0xFF4CAF17));
    expect(style?.backgroundColor?.resolve({}), const Color(0xFF1D2A22));
  });

  testWidgets('light theme: Saqlash keeps the default colors', (tester) async {
    final style = await _style(tester, ThemeMode.light);
    expect(style?.foregroundColor, isNull);
    expect(style?.backgroundColor, isNull);
  });
}
