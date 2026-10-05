import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class NamozVaqtlariApp extends ConsumerWidget {
  const NamozVaqtlariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // designSize matches the qcf_quran package's reference device, so its
    // sp/h Mushaf scaling (used by the Qur'on kitob reader) stays accurate.
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Namoz Vaqtlari',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
