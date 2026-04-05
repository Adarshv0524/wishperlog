import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/features/home/presentation/home_screen_layout.dart';
import 'package:wishperlog/features/notes/presentation/screens/folder_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/sign_in_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/telegram_screen.dart';
import 'package:wishperlog/features/search/presentation/search_screen.dart';
import 'package:wishperlog/features/settings/presentation/screens/settings_screen.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/features/overlay/presentation/system_banner_overlay.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SignInScreen()),
    GoRoute(path: '/signin', builder: (context, state) => const SignInScreen()),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/telegram',
      builder: (context, state) => const TelegramScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreenLayout(),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/folder',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is NoteCategory) {
          return FolderScreen(category: extra);
        }

        final raw =
            state.uri.queryParameters['category'] ??
            state.pathParameters['category'] ??
            'general';
        return FolderScreen(category: parseCategory(raw));
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/system_banner',
      builder: (context, state) => SystemBannerOverlay(
        mode: state.uri.queryParameters['mode'] ?? 'truecaller',
      ),
    ),
  ],
  redirect: (context, state) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final isOnboarding =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/signin' ||
          state.matchedLocation == '/permissions' ||
          state.matchedLocation == '/telegram';

      if (!isAuthenticated && !isOnboarding) {
        return '/';
      }
      if (isAuthenticated && isOnboarding) {
        return '/home';
      }
      return null;
    } catch (e) {
      // If Firebase auth check fails during initialization, stay on current route
      debugPrint('[Router] Auth check error: $e');
      return null;
    }
  },
);
