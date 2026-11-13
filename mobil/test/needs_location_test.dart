import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/auth/data/models/user_model.dart';
import 'package:mobil/features/auth/presentation/providers/auth_provider.dart';

void main() {
  const bare = UserModel(id: '1', email: 'a@example.com');
  const located = UserModel(
    id: '1',
    email: 'a@example.com',
    region: 'Toshkent',
    district: 'Chilonzor',
  );

  test('a new account is asked for its location', () {
    expect(const AuthAuthenticated(bare, isNewUser: true).needsLocation, true);
  });

  test('an existing account without a location (made on the web) is asked', () {
    expect(const AuthAuthenticated(bare).needsLocation, true);
  });

  test('an account with a saved location is not asked', () {
    expect(const AuthAuthenticated(located).needsLocation, false);
  });
}
