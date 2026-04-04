import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/features/home/presentation/screens/home_screen.dart';
import 'package:wishperlog/features/notes/presentation/screens/folder_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/sign_in_screen.dart';
import 'package:wishperlog/features/settings/presentation/screens/overlay_customization_screen.dart';
import 'package:wishperlog/features/settings/presentation/screens/settings_screen.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

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
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/folder',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is NoteCategory) {
          return FolderScreen(category: extra);
        }

        final raw = state.uri.queryParameters['category'] ??
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
      path: '/settings/overlay-customization',
      builder: (context, state) => const OverlayCustomizationScreen(),
    ),
  ],
  redirect: (context, state) {
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
  },
);
