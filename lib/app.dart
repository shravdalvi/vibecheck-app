import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app.dart';

import 'features/debug/design_gallery_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/consent/consent_screen.dart';
import 'features/permissions/location_permission_screen.dart';
import 'features/event_join/event_join_screen.dart';
import 'features/main_layout.dart';
import 'features/home/home_screen.dart';
import 'features/venue_map/venue_map_screen.dart';
import 'features/recommendations/recommendation_detail_screen.dart';
import 'features/emergency/sos_screen.dart';
import 'features/settings_privacy/settings_screen.dart';
import 'features/connection_status/connection_status_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (c, s) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (c, s) => WelcomeScreen(onContinue: () => c.go('/login')),
    ),
    GoRoute(
      path: '/login',
      builder: (c, s) => LoginScreen(
        onLoginSuccess: () => c.go('/consent'),
        onGoToSignup: () => c.go('/signup'),
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (c, s) => SignupScreen(
        onSignupSuccess: () => c.go('/consent'),
        onGoToLogin: () => c.go('/login'),
      ),
    ),
    GoRoute(
      path: '/consent',
      builder: (c, s) => ConsentScreen(
        onAgree: () => c.go('/permissions'),
        onDecline: () => c.go('/welcome'),
      ),
    ),
    GoRoute(
      path: '/permissions',
      builder: (c, s) => LocationPermissionScreen(
        onAllow: () => c.go('/join'),
        onOpenSettings: () {},
      ),
    ),
    GoRoute(
      path: '/join',
      builder: (c, s) => EventJoinScreen(
        onJoined: () => c.go('/home'),
        onScanQr: () {},
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (c, s) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (c, s) => const VenueMapScreen(),
    ),
    GoRoute(
      path: '/recommendation',
      builder: (c, s) => const RecommendationDetailScreen(),
    ),
    GoRoute(
      path: '/sos',
      builder: (c, s) => const SosScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (c, s) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/connection',
      builder: (c, s) => const ConnectionStatusScreen(),
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
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
