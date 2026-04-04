import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/background/work_manager_service.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/overlay_v1/overlay_coordinator.dart';
import 'package:wishperlog/features/overlay_v1/presentation/widgets/overlay_permission_explainer_dialog.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserRepository _users = sl<UserRepository>();
  final AppPreferencesRepository _prefs = sl<AppPreferencesRepository>();
  final ExternalSyncService _sync = sl<ExternalSyncService>();
  final FcmSyncService _fcm = sl<FcmSyncService>();
  final OverlayCoordinator _overlayCoordinator = sl<OverlayCoordinator>();

  TimeOfDay _digestTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime? _lastSyncedAt;
  bool _syncingNow = false;
  bool _updatingOverlayToggle = false;
  bool _floatingCaptureEnabled = false;
  NotificationSettings? _notificationSettings;

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  @override
  void initState() {
    super.initState();
    _hydrateLocalPrefs();
    _hydrateNotificationPermission();
    _hydrateOverlayToggle();
  }

  Future<void> _hydrateOverlayToggle() async {
    await _overlayCoordinator.hydrate();
    if (!mounted) {
      return;
    }
    
    // Check actual OS permission state, not just local coordinator state
    final osPermissionGranted = await _overlayCoordinator.isPermissionGranted();
    final isVisible = _overlayCoordinator.state.value.isVisible;
    
    // If OS says permission is granted but coordinator says not visible, 
    // sync by showing the bubble
    final shouldBeVisible = osPermissionGranted || isVisible;
    if (osPermissionGranted && !isVisible) {
      debugPrint('[Settings] OS permission is granted but overlay hidden. Auto-booting...');
      await _overlayCoordinator.showIdleBubble();
    }
    
    setState(() {
      _floatingCaptureEnabled = shouldBeVisible;
    });
  }

  Future<void> _hydrateLocalPrefs() async {
    final digest = await _prefs.getDigestTime();

    if (!mounted) {
      return;
    }
    setState(() {
      _digestTime = digest;
    });
  }

  Future<void> _hydrateNotificationPermission() async {
    final settings = await _fcm.getNotificationSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _notificationSettings = settings;
    });
  }

  Future<void> _setDigestTime(TimeOfDay value) async {
    await HapticFeedback.lightImpact();
    await _prefs.setDigestTime(value);
    await _users.updateDigestTime(_formatTime(value));
    await WorkManagerService.registerTelegramDailyDigest();

    if (!mounted) return;
    setState(() {
      _digestTime = value;
    });
  }

  Future<void> _requestNotificationPermission() async {
    await HapticFeedback.lightImpact();
    final settings = await _fcm.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _users.updateFcmToken(token);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notifications enabled.')));
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications denied. Enable from system settings.'),
        ),
      );
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _notificationSettings = settings;
    });
  }

  Future<void> _setFloatingCapture(bool value) async {
    if (_updatingOverlayToggle) {
      return;
    }

    await HapticFeedback.lightImpact();
    setState(() {
      _updatingOverlayToggle = true;
    });

    bool success = false;
    try {
      if (value) {
        success = await _enableFloatingCapture();
      } else {
        await _overlayCoordinator.hideOverlay();
        success = true;
      }
    } catch (e) {
      debugPrint('[Settings] Error setting floating capture: $e');
      success = false;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _updatingOverlayToggle = false;
      // Only set toggle ON if both conditions are true:
      // 1. We successfully completed the operation
      // 2. The coordinator reports that overlay is visible
      _floatingCaptureEnabled = (success && value && _overlayCoordinator.state.value.isVisible) || (!value && !success);
    });
  }

  void _openOverlayCustomization() {
    context.push('/settings/overlay-customization');
  }

  Future<bool> _enableFloatingCapture() async {
    try {
      // Step 1: Check OS permission state
      debugPrint('[Settings] Checking OS overlay permission...');
      var granted = await _overlayCoordinator.isPermissionGranted();

      if (!granted) {
        debugPrint('[Settings] OS permission not granted, requesting...');
        if (!mounted) {
          return false;
        }

        final proceed = await showOverlayPermissionExplainerDialog(context);
        if (!proceed) {
          debugPrint('[Settings] User declined permission request');
          return false;
        }

        granted = await _overlayCoordinator.requestPermission();

        if (!granted) {
          debugPrint('[Settings] Permission request failed');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Floating Capture permission was not granted. You can keep using the app normally.',
                ),
              ),
            );
          }
          return false;
        }
      }

      // Step 2: OS permission is confirmed granted - now boot the overlay
      debugPrint('[Settings] OS permission granted, starting overlay...');
      final shown = await _overlayCoordinator.showIdleBubble();

      if (!shown) {
        debugPrint('[Settings] Failed to show overlay bubble');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Floating Capture could not start right now and has been disabled safely.',
              ),
            ),
          );
        }
        return false;
      }

      debugPrint('[Settings] Overlay started successfully');
      return true;
    } catch (e, st) {
      debugPrint('[Settings] Exception in _enableFloatingCapture: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An error occurred while enabling Floating Capture.',
            ),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _syncNow() async {
    if (_syncingNow) {
      return;
    }
    await HapticFeedback.lightImpact();
    setState(() {
      _syncingNow = true;
    });

    final result = await _sync.syncNow();

    if (!mounted) {
      return;
    }
    setState(() {
      _syncingNow = false;
      _lastSyncedAt = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Synced ${result.updated}/${result.processed} notes'),
      ),
    );
  }

  Future<void> _connectTelegram() async {
    await HapticFeedback.lightImpact();
    final bot = AppEnv.telegramBotUsername;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (bot.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TELEGRAM_BOT_USERNAME is missing in .env'),
        ),
      );
      return;
    }

    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first to connect Telegram.')),
      );
      return;
    }

    final shouldLaunch = await _showTelegramConnectSheet(bot: bot, uid: uid);
    if (shouldLaunch != true) {
      return;
    }

    final uri = Uri(
      scheme: 'tg',
      host: 'resolve',
      queryParameters: {
        'domain': bot,
        'start': uid,
      },
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telegram app not available on device.')),
      );
    }
  }

  Future<bool?> _showTelegramConnectSheet({
    required String bot,
    required String uid,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connect Telegram',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'You will be redirected to @$bot. Tap Start in Telegram to link your account and enable digest delivery.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Open Telegram'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDigestTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _digestTime,
    );
    if (picked == null) return;
    await _setDigestTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Settings'),
      ),
      body: GlassPageBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
          children: [
            _sectionHeader('Account'),
            _accountCard(authUser),
            const SizedBox(height: 16),
            _sectionHeader('Telegram'),
            _telegramCard(),
            const SizedBox(height: 16),
            _sectionHeader('Preferences'),
            _preferencesCard(),
            const SizedBox(height: 16),
            _sectionHeader('Notifications'),
            _notificationsCard(),
            const SizedBox(height: 16),
            _sectionHeader('Sync'),
            _syncCard(),
          ],
        ),
      ),
    );
  }

  Widget _accountCard(User? authUser) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: (authUser?.photoURL?.isNotEmpty ?? false)
                  ? NetworkImage(authUser?.photoURL ?? '')
                    : null,
                child: (authUser?.photoURL?.isNotEmpty ?? false)
                    ? null
                    : const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authUser?.displayName ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      authUser?.email ?? '-',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Google Account: Connected',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  await HapticFeedback.lightImpact();
                  final ok = await _sync.reconnectGoogle();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Google reconnected'
                            : 'Reconnect canceled or failed',
                      ),
                    ),
                  );
                },
                child: const Text('Reconnect Google'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await HapticFeedback.lightImpact();
                  await _users.signOut();
                  if (!mounted) return;
                  context.go('/');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _telegramCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _users.watchCurrentUserDocument(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final telegramConnected =
            data != null &&
            data['telegram_chat_id']?.toString().isNotEmpty == true;

        return GlassContainer(
          padding: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    telegramConnected ? 'Connected' : 'Not Connected',
                    style: TextStyle(
                      fontSize: 13,
                      color: telegramConnected
                          ? const Color(0xFF15803D)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _connectTelegram,
                    child: const Text('Connect Telegram'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Daily Digest Time: ${_formatTime(_digestTime)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDigestTime,
                    child: const Text('Change'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _preferencesCard() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return SwitchListTile.adaptive(
                value: mode == ThemeMode.dark,
                onChanged: (_) async {
                  final cubit = context.read<ThemeCubit>();
                  await HapticFeedback.lightImpact();
                  await cubit.toggleLightDark();
                },
                title: const Text('App Theme'),
                subtitle: Text(mode == ThemeMode.dark ? 'Dark' : 'Light'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              );
            },
          ),
          ListTile(
            onTap: _openOverlayCustomization,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text('Floating Capture'),
            subtitle: Text(
              _floatingCaptureEnabled
                  ? 'Enabled'
                  : 'Off (requires Display over other apps permission)',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Customize overlay',
                  onPressed: _openOverlayCustomization,
                  icon: const Icon(Icons.tune_rounded),
                ),
                Switch.adaptive(
                  value: _floatingCaptureEnabled,
                  onChanged: _updatingOverlayToggle
                      ? null
                      : _setFloatingCapture,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationsCard() {
    final status = _notificationSettings?.authorizationStatus;
    final enabled =
        status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              enabled
                  ? 'Push Notifications: Enabled'
                  : 'Push Notifications: Off',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () async {
              await HapticFeedback.lightImpact();
              await _requestNotificationPermission();
            },
            child: Text(enabled ? 'Refresh' : 'Enable'),
          ),
        ],
      ),
    );
  }

  Widget _syncCard() {
    final syncedAt = _lastSyncedAt;
    final last = _lastSyncedAt == null
        ? 'Never'
        : syncedAt
              ?.toLocal()
              .toIso8601String()
              .replaceFirst('T', ' ')
              .split('.')
              .first ??
            'Never';

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Last Synced: $last',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          ElevatedButton(
            onPressed: _syncingNow ? null : _syncNow,
            child: Text(_syncingNow ? 'Syncing...' : 'Sync Now'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
