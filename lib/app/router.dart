import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/features/home/presentation/home_screen_layout.dart';
import 'package:wishperlog/features/notes/presentation/screens/folder_screen.dart';
import 'package:wishperlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/sign_in_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/telegram_screen.dart';
import 'package:wishperlog/features/search/presentation/search_screen.dart';
import 'package:wishperlog/features/settings/presentation/screens/settings_screen.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/features/notes/presentation/screens/note_view_screen.dart';
import 'package:wishperlog/features/overlay/presentation/system_banner_overlay.dart';

CustomTransitionPage<T> _buildPage<T>({
  required LocalKey key,
  required Widget child,
  Offset beginOffset = const Offset(0.04, 0.03),
  Duration duration = const Duration(milliseconds: 360),
}) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 280),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SignInScreen(),
        beginOffset: const Offset(0, 0.04),
      ),
    ),
    GoRoute(
      path: '/permissions',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const PermissionsScreen(),
        beginOffset: const Offset(0, 0.06),
      ),
    ),
    GoRoute(
      path: '/telegram',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const TelegramScreen(),
        beginOffset: const Offset(0, 0.06),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const HomeScreenLayout(),
        beginOffset: const Offset(0.02, 0.035),
        duration: const Duration(milliseconds: 420),
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SearchScreen(),
        beginOffset: const Offset(0.03, 0.08),
      ),
    ),
    GoRoute(
      path: '/notes/:noteId',
      pageBuilder: (context, state) {
        final noteId = state.pathParameters['noteId'] ?? '';
        return _buildPage(
          key: state.pageKey,
          child: NoteDetailScreen(noteId: noteId),
          beginOffset: const Offset(0.04, 0.02),
          duration: const Duration(milliseconds: 380),
        );
      },
    ),
    GoRoute(
      path: '/notes/:noteId/view',
      pageBuilder: (context, state) {
        final extra = state.extra;
        // extra must be a Note object when using context.push('/notes/x/view', extra: note)
        if (extra is Note) {
          return _buildPage(
            key: state.pageKey,
            child: NoteViewScreen(note: extra),
            beginOffset: const Offset(0.0, 0.04),
            duration: const Duration(milliseconds: 400),
          );
        }
        // Fallback: redirect to edit screen
        final noteId = state.pathParameters['noteId'] ?? '';
        return _buildPage(
          key: state.pageKey,
          child: NoteDetailScreen(noteId: noteId),
          beginOffset: const Offset(0.04, 0.02),
        );
      },
    ),
    GoRoute(
      path: '/folder',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is NoteCategory) {
          return _buildPage(
            key: state.pageKey,
            child: FolderScreen(category: extra),
            beginOffset: const Offset(0.05, 0.04),
            duration: const Duration(milliseconds: 400),
          );
        }

        final raw =
            state.uri.queryParameters['category'] ??
            state.pathParameters['category'] ??
            'general';
        return _buildPage(
          key: state.pageKey,
          child: FolderScreen(category: parseCategory(raw)),
          beginOffset: const Offset(0.05, 0.04),
          duration: const Duration(milliseconds: 400),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        beginOffset: const Offset(0.02, 0.05),
      ),
    ),
    GoRoute(
      path: '/system_banner',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SystemBannerOverlay(),
        beginOffset: const Offset(0, 0.08),
        duration: const Duration(milliseconds: 260),
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
          state.matchedLocation == '/permissions';

      if (!isAuthenticated && !isOnboarding) {
        return '/';
      }
      if (isAuthenticated && isOnboarding) {
        return '/home';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Router] FirebaseAuthException during redirect: ${e.message}');
      return '/'; // Sign-in is the safe fallback for all auth errors
    } catch (e) {
      debugPrint('[Router] Unexpected redirect error: $e');
      return '/'; // Never strand the user on a missing route
    }  },
);