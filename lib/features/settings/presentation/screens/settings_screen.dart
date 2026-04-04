import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
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

  bool _volumeShortcut = true;
  TimeOfDay _digestTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime? _lastSyncedAt;
  bool _syncingNow = false;
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
  }

  Future<void> _hydrateLocalPrefs() async {
    final volume = await _prefs.isVolumeShortcutEnabled();
    final digest = await _prefs.getDigestTime();

    if (!mounted) {
      return;
    }
    setState(() {
      _volumeShortcut = volume;
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

  Future<void> _setVolumeShortcut(bool value) async {
    await HapticFeedback.lightImpact();
    await _prefs.setVolumeShortcutEnabled(value);
    if (!mounted) return;
    setState(() {
      _volumeShortcut = value;
    });
  }

  Future<void> _setDigestTime(TimeOfDay value) async {
    await HapticFeedback.lightImpact();
    await _prefs.setDigestTime(value);
    await _users.updateDigestTime(_formatTime(value));

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
    if (bot.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TELEGRAM_BOT_USERNAME is missing in .env'),
        ),
      );
      return;
    }

    final uri = Uri.parse('tg://resolve?domain=$bot');
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telegram app not available on device.')),
      );
    }
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
                    ? NetworkImage(authUser!.photoURL!)
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
          ListTile(
            title: const Text('Overlay Settings & Behavior'),
            subtitle: const Text(
              'Bubble opacity, snap physics, and banner behavior.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              context.push('/settings/overlay-customization');
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          const Divider(height: 1),
          SwitchListTile.adaptive(
            value: _volumeShortcut,
            onChanged: _setVolumeShortcut,
            title: const Text('Volume Button Shortcut'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          const Divider(height: 1),
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
    final last = _lastSyncedAt == null
        ? 'Never'
        : _lastSyncedAt!
              .toLocal()
              .toIso8601String()
              .replaceFirst('T', ' ')
              .split('.')
              .first;

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
