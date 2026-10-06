import "package:flutter_localizations/flutter_localizations.dart";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app.dart';

import 'features/home/home_screen.dart';
import 'features/zones/zones_screen.dart';
import 'features/map/map_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/navigation/app_scaffold.dart';
import 'features/design_gallery/design_gallery_screen.dart';
import 'features/auth/login_screen.dart';
// Note: We temporarily keep login for testing if needed.

final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/login',
      builder: (c, s) => LoginScreen(
        onLoginSuccess: () => c.go('/home'),
        onGoToSignup: () {},
      ),
    ),
    GoRoute(
      path: '/design-gallery',
      builder: (c, s) => const DesignGalleryScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/zones',
              builder: (context, state) => const ZonesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class VibecheckApp extends ConsumerWidget {
  const VibecheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.DISPLAY_NAME,
      theme: AppTheme.dark,
      highContrastTheme: AppTheme.highContrastDark,




      themeMode: ThemeMode.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
      ],
    );
  }
}
