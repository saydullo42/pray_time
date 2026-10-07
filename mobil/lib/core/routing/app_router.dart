import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dua/data/models/dua_model.dart';
import '../../features/dua/presentation/screens/dua_categories_screen.dart';
import '../../features/dua/presentation/screens/dua_detail_screen.dart';
import '../../features/dua/presentation/screens/dua_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/prayer_times/presentation/screens/custom_prayer_time_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/quran/data/models/surah_model.dart';
import '../../features/quran/presentation/screens/quran_audio_player_screen.dart';
import '../../features/quran/presentation/screens/quran_list_screen.dart';
import '../../features/quran/presentation/screens/quran_mushaf_reader_screen.dart';
import '../../features/quran/presentation/screens/quran_reciter_list_screen.dart';
import '../../features/quran/presentation/screens/quran_translation_reader_screen.dart';
import '../../features/quran/presentation/screens/quran_video_screen.dart';
import '../../features/quran/presentation/screens/surah_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/tracking/presentation/screens/yearly_tracking_screen.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(path: RouteNames.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RouteNames.login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) => OtpScreen(phoneNumber: state.extra as String),
      ),
      GoRoute(path: RouteNames.register, builder: (context, state) => const RegisterScreen()),

      // Main bottom-nav shell: Home / Yillik tracking / Qur'an / Duo / Profile
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.trackingYearly,
              builder: (context, state) => const YearlyTrackingScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.quranList,
              builder: (context, state) => const QuranListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.duaCategories,
              builder: (context, state) => const DuaCategoriesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.profile, builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // Pushed on top of the shell (full-screen, not part of the bottom nav)
      GoRoute(
        path: RouteNames.prayerTimes,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrayerTimesScreen(),
        routes: [
          GoRoute(
            path: 'custom',
            builder: (context, state) => const CustomPrayerTimeScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.quranBookList,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SurahListScreen(mode: QuranListMode.book),
      ),
      GoRoute(
        path: RouteNames.quranTranslationList,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SurahListScreen(mode: QuranListMode.translation),
      ),
      GoRoute(
        path: RouteNames.quranTranslationReader,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            QuranTranslationReaderScreen(surah: state.extra as SurahModel),
      ),
      GoRoute(
        path: RouteNames.quranReciterList,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QuranReciterListScreen(),
      ),
      GoRoute(
        path: RouteNames.quranAudioList,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final reciter = state.extra as ReciterModel;
          return SurahListScreen(
            mode: QuranListMode.audio,
            reciterId: int.parse(reciter.id),
            reciterName: reciter.name,
          );
        },
      ),
      GoRoute(
        path: RouteNames.quranPdfReader,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuranMushafReaderScreen(surah: state.extra as SurahModel),
      ),
      GoRoute(
        path: RouteNames.quranAudioPlayer,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuranAudioPlayerScreen(surah: state.extra as SurahModel),
      ),
      GoRoute(
        path: RouteNames.quranVideo,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuranVideoScreen(surah: state.extra as SurahModel),
      ),
      GoRoute(
        path: '${RouteNames.duaListByCategory}/:categoryId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DuaListScreen(
          categoryId: state.pathParameters['categoryId']!,
          categoryName: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.duaDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DuaDetailScreen(dua: state.extra as DuaModel),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.notificationSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
