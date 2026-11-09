import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobil/core/routing/route_names.dart';
import 'package:mobil/core/storage/local_storage_service.dart';
import 'package:mobil/features/auth/data/models/user_model.dart';
import 'package:mobil/features/auth/presentation/screens/register_location_screen.dart';
import 'package:mobil/features/prayer_times/presentation/providers/region_selection_provider.dart';
import 'package:mobil/features/profile/data/repositories/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfile implements ProfileRepository {
  final saved = <({String region, String district})>[];
  bool fail = false;

  @override
  Future<UserModel> updateLocation({
    required String region,
    required String district,
  }) async {
    if (fail) throw Exception('offline');
    saved.add((region: region, district: district));
    return UserModel(
      id: '1',
      email: 'a@example.com',
      region: region,
      district: district,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _container(_FakeProfile profile) async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
      profileRepositoryProvider.overrideWithValue(profile),
    ],
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('region selection and the account', () {
    test(
      'setSelection keeps the choice on the device and saves it on the account',
      () async {
        final profile = _FakeProfile();
        final container = await _container(profile);
        await container
            .read(regionSelectionProvider.notifier)
            .setSelection('Andijon viloyati', 'Baliqchi');
        final selection = container.read(regionSelectionProvider);
        expect(
          (selection.regionName, selection.districtName),
          ('Andijon viloyati', 'Baliqchi'),
        );
        expect(profile.saved, [
          (region: 'Andijon viloyati', district: 'Baliqchi'),
        ]);
      },
    );

    test(
      'setSelection reports a failed save but keeps the choice on the device',
      () async {
        final profile = _FakeProfile()..fail = true;
        final container = await _container(profile);
        await expectLater(
          container
              .read(regionSelectionProvider.notifier)
              .setSelection('Buxoro viloyati', 'Buxoro shahri'),
          throwsException,
        );
        expect(
          container.read(regionSelectionProvider).regionName,
          'Buxoro viloyati',
        );
      },
    );

    test(
      'changing the region later is saved on the account too, and never throws',
      () async {
        final profile = _FakeProfile();
        final container = await _container(profile);
        await container
            .read(regionSelectionProvider.notifier)
            .setRegion('Namangan viloyati');
        await _settle();
        expect(profile.saved.single.region, 'Namangan viloyati');

        profile.fail = true;
        await container
            .read(regionSelectionProvider.notifier)
            .setRegion('Xorazm viloyati');
        await _settle();
        expect(
          container.read(regionSelectionProvider).regionName,
          'Xorazm viloyati',
        );
      },
    );

    test('an account that has a location overrides this device', () async {
      final profile = _FakeProfile();
      final container = await _container(profile);
      await container
          .read(regionSelectionProvider.notifier)
          .adoptFromAccount(
            const UserModel(
              id: '1',
              email: 'a@example.com',
              region: 'Samarqand viloyati',
              district: 'Samarqand shahri',
            ),
          );
      final selection = container.read(regionSelectionProvider);
      expect(
        (selection.regionName, selection.districtName),
        ('Samarqand viloyati', 'Samarqand shahri'),
      );
      expect(profile.saved, isEmpty); // nothing to upload
    });

    test(
      'an account without a location gets the choice made on this device',
      () async {
        SharedPreferences.setMockInitialValues({
          'selected_region': 'Farg\'ona viloyati',
        });
        final profile = _FakeProfile();
        final container = await _container(profile);
        await container
            .read(regionSelectionProvider.notifier)
            .adoptFromAccount(const UserModel(id: '1', email: 'a@example.com'));
        expect(profile.saved.length, 1);
      },
    );
  });

  group('registration screen', () {
    Future<void> openScreen(WidgetTester tester, _FakeProfile profile) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: RouteNames.registerLocation,
        routes: [
          GoRoute(
            path: RouteNames.registerLocation,
            builder: (_, _) => const RegisterLocationScreen(),
          ),
          GoRoute(path: RouteNames.home, builder: (_, _) => const Text('HOME')),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(
              LocalStorageService(prefs),
            ),
            profileRepositoryProvider.overrideWithValue(profile),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    ElevatedButton continueButton(WidgetTester tester) =>
        tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Davom etish'),
        );

    testWidgets('both choices are needed before continuing, then it is saved', (
      tester,
    ) async {
      final profile = _FakeProfile();
      await openScreen(tester, profile);

      expect(continueButton(tester).onPressed, isNull);

      await tester.tap(find.text('Viloyatni tanlang').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Andijon viloyati'));
      await tester.pumpAndSettle();
      expect(
        continueButton(tester).onPressed,
        isNull,
      ); // the district is still missing

      await tester.tap(find.text('Tumanni tanlang').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Baliqchi tumani'));
      await tester.pumpAndSettle();
      expect(continueButton(tester).onPressed, isNotNull);

      await tester.tap(find.text('Davom etish'));
      await tester.pumpAndSettle();
      expect(profile.saved, [
        (region: 'Andijon viloyati', district: 'Baliqchi'),
      ]);
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('the district list opens only after a region is chosen', (
      tester,
    ) async {
      await openScreen(tester, _FakeProfile());
      final district = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Tumanni tanlang'),
      );
      expect(district.onPressed, isNull);
    });

    testWidgets('changing the region clears the district', (tester) async {
      await openScreen(tester, _FakeProfile());
      await tester.tap(find.text('Viloyatni tanlang').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Andijon viloyati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tumanni tanlang').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Baliqchi tumani'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Andijon viloyati').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buxoro viloyati'));
      await tester.pumpAndSettle();
      expect(find.text('Tumanni tanlang'), findsOneWidget);
      expect(continueButton(tester).onPressed, isNull);
    });

    testWidgets('a failed save keeps the person on the screen with a message', (
      tester,
    ) async {
      final profile = _FakeProfile()..fail = true;
      await openScreen(tester, profile);
      await tester.tap(find.text('Viloyatni tanlang').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Andijon viloyati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tumanni tanlang').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Baliqchi tumani'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Davom etish'));
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsNothing);
      expect(find.textContaining("Saqlab bo'lmadi"), findsOneWidget);
    });
  });
}
