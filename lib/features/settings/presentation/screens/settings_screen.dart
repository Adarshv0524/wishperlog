import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/overlay/overlay_customisation_sheet.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/features/settings/presentation/widgets/digest_schedule_section.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const MethodChannel _overlayChannel = MethodChannel(
    'wishperlog/overlay',
  );

  final UserRepository _users = sl<UserRepository>();
  final AppPreferencesRepository _prefs = sl<AppPreferencesRepository>();
  final ExternalSyncService _sync = sl<ExternalSyncService>();
  final TelegramService _telegram = sl<TelegramService>();
  final AiClassifierRouter _aiRouter = sl<AiClassifierRouter>();
  final OverlayNotifier _overlayNotifier = sl<OverlayNotifier>();

  List<TimeOfDay> _digestTimes = const [TimeOfDay(hour: 9, minute: 0)];
  DateTime? _lastSyncedAt;
  NotificationSettings? _notificationSettings;

  bool _syncingNow = false;
  bool _overlayUpdating = false;
  bool _reconnectingGoogle = false;
  bool _savingDigest = false;
  String _speechLanguage = 'en-US';
  bool   _speechPreferOffline = false;
  // Overlay customisation sheet is driven entirely by OverlayNotifier.

  String? _telegramChatId;

  Timer? _speechApplyDebounce;

  static const List<Map<String, String>> _speechLanguageOptions = [
    {'code': 'en-US', 'label': 'English (US)'},
    {'code': 'en-IN', 'label': 'English (India)'},
    {'code': 'hi-IN', 'label': 'Hindi (India)'},
    {'code': 'bn-IN', 'label': 'Bengali'},
    {'code': 'ta-IN', 'label': 'Tamil'},
    {'code': 'te-IN', 'label': 'Telugu'},
    {'code': 'mr-IN', 'label': 'Marathi'},
    {'code': 'gu-IN', 'label': 'Gujarati'},
    {'code': 'kn-IN', 'label': 'Kannada'},
    {'code': 'ml-IN', 'label': 'Malayalam'},
    {'code': 'pa-IN', 'label': 'Punjabi'},
    {'code': 'es-ES', 'label': 'Spanish'},
    {'code': 'fr-FR', 'label': 'French'},
    {'code': 'de-DE', 'label': 'German'},
    {'code': 'ja-JP', 'label': 'Japanese'},
  ];

  @override
  void initState() {
    super.initState();
    _hydrateLocalPrefs();
    _hydrateNotificationPermission();
    _hydrateTelegramId();
    _hydrateSpeechSettings();
  }

  @override
  void dispose() {
    _speechApplyDebounce?.cancel();
    super.dispose();
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  Future<void> _hydrateLocalPrefs() async {
    final digestTimes = await _prefs.getDigestTimes();
    if (mounted) {
      setState(() => _digestTimes = digestTimes);
    }
  }

  Future<void> _hydrateNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (mounted) {
        setState(() => _notificationSettings = settings);
      }
    } catch (e) {
      debugPrint('[Settings] Notification permission check error: $e');
    }
  }

  Future<void> _hydrateTelegramId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await _users.watchCurrentUserDocument().first;
      final chatId = (doc?['telegram_chat_id'] ?? '').toString().trim();
      if (mounted) {
        setState(() {
          _telegramChatId = chatId.isEmpty ? null : chatId;
        });
      }
    } catch (e) {
      debugPrint('[Settings] Telegram hydrate error: $e');
    }
  }

  Future<void> _toggleOverlay() async {
    if (_overlayUpdating) return;
    setState(() => _overlayUpdating = true);
    try {
      final newValue = !_overlayNotifier.isEnabled;
      await _overlayNotifier.setEnabled(newValue);
      unawaited(_users.updateOverlayVisibility(newValue));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update overlay setting')),
        );
      }
    } finally {
      if (mounted) setState(() => _overlayUpdating = false);
    }
  }

  Future<void> _openOverlayCustomiser() async {
    final notifier = _overlayNotifier;
    await showOverlayCustomisationSheet(
      context,
      notifier.overlaySettings,
      (updated) => notifier.saveOverlaySettings(updated),
    );
  }

  Future<void> _hydrateSpeechSettings() async {
    try {
      final values = await _overlayChannel.invokeMapMethod<String, dynamic>(
        'getSpeechSettings',
      );
      if (!mounted || values == null) return;
      setState(() {
        _speechLanguage = (values['language'] as String?) ?? 'en-US';
        _speechPreferOffline = (values['preferOffline'] as bool?) ?? false;
      });
    } catch (e) {
      debugPrint('[Settings] _hydrateSpeechSettings error: $e');
    }
  }

  Future<void> _applySpeechSettings() async {
    try {
      await _overlayChannel.invokeMethod<void>('updateSpeechSettings', {
        'language': _speechLanguage,
        'preferOffline': _speechPreferOffline,
      });
    } catch (e) {
      debugPrint('[Settings] _applySpeechSettings error: $e');
    }
  }

  void _scheduleSpeechSettingsApply() {
    _speechApplyDebounce?.cancel();
    _speechApplyDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_applySpeechSettings());
    });
  }

  Future<void> _openSpeechPackSettings() async {
    try {
      await _overlayChannel.invokeMethod<bool>('downloadSpeechLanguagePack', {
        'language': _speechLanguage,
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open speech language settings'),
          ),
        );
      }
    }
  }

  // ── 15-minute slot picker ─────────────────────────────────────────────────

  Future<void> _addDigestTime() async {
    final slot = await showMinuteWiseTimePicker(context, _digestTimes);
    if (slot == null || !mounted) return;

    final exists = _digestTimes.any(
      (t) => t.hour * 60 + t.minute == slot.hour * 60 + slot.minute,
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This digest time already exists')),
      );
      return;
    }
    final updated = [..._digestTimes, slot]
      ..sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
    await _persistDigestTimes(updated);
  }

  Future<void> _removeDigestTime(TimeOfDay time) async {
    if (_digestTimes.length <= 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keep at least one digest schedule')),
        );
      }
      return;
    }
    final min = time.hour * 60 + time.minute;
    final updated = _digestTimes
        .where((t) => t.hour * 60 + t.minute != min)
        .toList();
    await _persistDigestTimes(updated);
  }

  Future<void> _persistDigestTimes(List<TimeOfDay> times) async {
    setState(() => _savingDigest = true);
    try {
      await _prefs.setDigestTimes(times);

      // Convert to UTC "HH:MM" strings for the Cloudflare Worker to match against.
      final nowLocal = DateTime.now();
      final utcOffsetMin = nowLocal.timeZoneOffset.inMinutes;
      final utcSlots = times.map((t) {
        final localMin = t.hour * 60 + t.minute;
        final utcMin = (localMin - utcOffsetMin) % (24 * 60);
        final normalized = utcMin < 0 ? utcMin + 24 * 60 : utcMin;
        final h = normalized ~/ 60;
        final m = normalized % 60;
        return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      }).toList();

      await _users.updateDigestTimes(times, utcSlots: utcSlots);

      if (mounted) setState(() => _digestTimes = times);
    } finally {
      if (mounted) setState(() => _savingDigest = false);
    }
  }

  Future<void> _syncNow() async {
    if (_syncingNow) return;
    setState(() => _syncingNow = true);
    try {
      await _sync.syncGoogleTaskCompletions();
      setState(() => _lastSyncedAt = DateTime.now());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _syncingNow = false);
    }
  }

  Future<void> _reconnectGoogle() async {
    if (_reconnectingGoogle) return;
    setState(() => _reconnectingGoogle = true);
    try {
      final ok = await _sync.reconnectGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Google reconnected' : 'Reconnection failed'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reconnectingGoogle = false);
    }
  }

  Future<void> _disconnectTelegram() async {
    if (_telegramChatId == null) return;
    try {
      await _users.updateTelegramChatId('');
      if (!mounted) return;
      setState(() => _telegramChatId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telegram connection cleared')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear Telegram connection: $e')),
        );
      }
    }
  }

  Future<void> _openTelegramBot() async {
    final botUsername = await _telegram.resolveBotUsername();
    if (botUsername == null || botUsername.isEmpty) return;
    final uri = Uri.parse('https://t.me/$botUsername');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _connectTelegramAuto() async {
    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in required to connect Telegram')),
        );
      }
      return;
    }
    final botUsername = await _telegram.resolveBotUsername();
    if (botUsername == null || botUsername.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Telegram bot is not configured (missing token or unreachable bot)',
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    await context.push('/telegram');
    await _hydrateTelegramId();
  }

  Future<void> _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (mounted) {
      setState(() => _notificationSettings = settings);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.reminders.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppColors.reminders,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sign out of WishperLog?',
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your local notes stay on this device. Cloud sync pauses until you sign in again.',
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.reminders.withValues(
                          alpha: 0.15,
                        ),
                        foregroundColor: AppColors.reminders,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _overlayNotifier.setEnabled(false);
      await _users.signOut();
      if (mounted) context.go('/signin');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.sizeOf(context).width < 720;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassTitleBar(
        title: 'Settings',
        subtitle: 'Preferences and integrations',
        onBack: _goBack,
      ),
      body: GlassPageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 8),
                      child: child,
                    ),
                  );
                },
                child: GlassContainer(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  borderRadius: BorderRadius.circular(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.tasks, Color(0xFF57C7FF)],
                          ),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                color: context.textPri,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Overlay, speech, sync, and digest controls in one place.',
                              style: TextStyle(
                                color: context.textSec,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _SectionHeader(label: 'Appearance'),
              _SettingsTile(
                title: 'Theme',
                subtitle: _themeModeLabel(context),
                leading: const Icon(Icons.palette_outlined),
                trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                  bloc: sl<ThemeCubit>(),
                  builder: (context, mode) {
                    if (isCompact) {
                      return SizedBox(
                        width: 124,
                        child: DropdownButton<ThemeMode>(
                          value: mode,
                          isExpanded: true,
                          icon: Icon(
                            Icons.expand_more_rounded,
                            color: context.textSec,
                          ),
                          underline: const SizedBox.shrink(),
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            sl<ThemeCubit>().setThemeMode(value);
                          },
                        ),
                      );
                    }

                    return SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.phone_android_outlined),
                          label: Text('System'),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) return;
                        sl<ThemeCubit>().setThemeMode(selection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.tasks,
                        selectedForegroundColor: Colors.white,
                        backgroundColor: context.surface1,
                        foregroundColor: context.textSec,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Capture Overlay'),
              ListenableBuilder(
                listenable: _overlayNotifier,
                builder: (context, _) => GlassContainer(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.tasks, Color(0xFF57C7FF)],
                              ),
                            ),
                            child: const Icon(
                              Icons.bubble_chart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Floating capture button',
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Use the customiser below to style the bubble and island together or separately.',
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: _overlayNotifier.isEnabled,
                            onChanged: (_) => _toggleOverlay(),
                            activeThumbColor: AppColors.tasks,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              _buildSettingsTile(
                icon: Icons.tune_rounded,
                title: 'Customise Overlay Appearance',
                subtitle: 'Style bubble and island in one place',
                onTap: _openOverlayCustomiser,
              ),
              const SizedBox(height: 8),

              _SectionHeader(label: 'Speech'),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                margin: const EdgeInsets.symmetric(vertical: 3),
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose recognition language and offline preference',
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      decoration: BoxDecoration(
                        color: context.surface1.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.textSec.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.mic_none_rounded,
                                color: context.textPri,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Speech Recognition',
                                style: TextStyle(
                                  color: context.textPri,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Used by Android speech-to-text while recording.',
                            style: TextStyle(
                              color: context.textSec,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue:
                                _speechLanguageOptions.any(
                                  (e) => e['code'] == _speechLanguage,
                                )
                                ? _speechLanguage
                                : _speechLanguageOptions.first['code'],
                            menuMaxHeight: 360,
                            isExpanded: true,
                            items: _speechLanguageOptions
                                .map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry['code'],
                                    child: Text(
                                      entry['label'] ?? entry['code'] ?? '',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _speechLanguage = value);
                              _scheduleSpeechSettingsApply();
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Recognition language',
                              filled: true,
                              fillColor: context.surface2.withValues(
                                alpha: 0.7,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: context.textSec.withValues(alpha: 0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: context.textSec.withValues(
                                    alpha: 0.16,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.tasks,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Prefer offline recognition'),
                            subtitle: const Text(
                              'Uses downloaded speech models when available',
                            ),
                            value: _speechPreferOffline,
                            onChanged: (value) {
                              setState(() => _speechPreferOffline = value);
                              _scheduleSpeechSettingsApply();
                            },
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: _openSpeechPackSettings,
                              icon: const Icon(
                                Icons.download_for_offline_outlined,
                              ),
                              label: const Text('Manage speech language packs'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Notifications'),
              _SettingsTile(
                title: 'Push notifications',
                subtitle: _notificationStatusLabel(),
                leading: const Icon(Icons.notifications_outlined),
                trailing:
                    _notificationSettings?.authorizationStatus ==
                        AuthorizationStatus.authorized
                    ? Icon(
                        Icons.check_circle_outline,
                        color: AppColors.followUp,
                      )
                    : TextButton(
                        onPressed: _requestNotificationPermission,
                        child: const Text('Enable'),
                      ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Daily Digest'),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                borderRadius: BorderRadius.circular(16),
                child: DigestScheduleSection(
                  digestTimes: _digestTimes,
                  saving: _savingDigest,
                  onAdd: _addDigestTime,
                  onRemove: _savingDigest ? (_) {} : _removeDigestTime,
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'AI Configuration'),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<AiProvider>(
                      segments: const [
                        ButtonSegment(
                          value: AiProvider.auto,
                          label: Text('Auto'),
                        ),
                        ButtonSegment(
                          value: AiProvider.gemini,
                          label: Text('Gemini'),
                        ),
                        ButtonSegment(
                          value: AiProvider.groq,
                          label: Text('Groq'),
                        ),
                      ],
                      selected: {_aiRouter.activeProvider},
                      onSelectionChanged: (Set<AiProvider> newSelection) async {
                        if (newSelection.isNotEmpty) {
                          await _aiRouter.setProvider(newSelection.first);
                          setState(() {});
                        }
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: context.surface1,
                        selectedBackgroundColor: AppColors.ideas,
                        selectedForegroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_aiRouter.activeProvider == AiProvider.auto)
                      _buildAiStatusBadge(
                        'Auto-fallback (Gemini -> Groq)',
                        true,
                        AppColors.ideas,
                      )
                    else if (_aiRouter.activeProvider == AiProvider.gemini)
                      _buildAiStatusBadge(
                        _aiRouter.geminiConfigured
                            ? 'Gemini API configured'
                            : 'Missing Gemini API Key in .env',
                        _aiRouter.geminiConfigured,
                        AppColors.tasks,
                      )
                    else if (_aiRouter.activeProvider == AiProvider.groq)
                      _buildAiStatusBadge(
                        _aiRouter.groqConfigured
                            ? 'Groq API configured'
                            : 'Missing Groq API Key in .env',
                        _aiRouter.groqConfigured,
                        const Color(0xFFF97316),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Telegram'),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.telegram, color: AppColors.tasks, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Telegram Chat ID (Override)',
                          style: TextStyle(
                            color: context.textPri,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: isCompact
                          ? [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _connectTelegramAuto,
                                  icon: const Icon(Icons.link_rounded),
                                  label: const Text('Connect in Telegram'),
                                ),
                              ),
                            ]
                          : [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _connectTelegramAuto,
                                  icon: const Icon(Icons.link_rounded),
                                  label: const Text('Connect in Telegram'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _openTelegramBot,
                                child: const Text('Open bot'),
                              ),
                            ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect in Telegram is the supported path. The app now links your verified chat automatically.',
                      style: TextStyle(color: context.textSec, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (_telegramChatId != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Connected: $_telegramChatId',
                              style: TextStyle(
                                color: AppColors.followUp,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _disconnectTelegram,
                            child: const Text('Disconnect'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        'Not connected yet.',
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Google Sync'),
              _SettingsTile(
                title: 'Sync Google Tasks',
                subtitle: _lastSyncedAt == null
                    ? 'Sync completions from Google Tasks'
                    : 'Last synced ${_formatRelativeTime(_lastSyncedAt!)}',
                leading: const Icon(Icons.sync_outlined),
                trailing: _syncingNow
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _syncNow,
                        child: const Text('Sync now'),
                      ),
              ),
              _SettingsTile(
                title: 'Reconnect Google account',
                subtitle: 'Re-authorize calendar & tasks access',
                leading: const Icon(Icons.account_circle_outlined),
                trailing: _reconnectingGoogle
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _reconnectGoogle,
                        child: const Text('Reconnect'),
                      ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Account'),
              _buildAccountTile(context),
              const SizedBox(height: 4),
              _SettingsTile(
                title: 'Sign out',
                subtitle: 'You will remain signed out until next login',
                leading: Icon(
                  Icons.logout_rounded,
                  color: isDark ? AppColors.reminders : Colors.redAccent,
                ),
                onTap: _signOut,
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'WishperLog',
                  style: TextStyle(
                    color: context.textSec,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return _SettingsTile(
      title: user.displayName ?? 'Signed in',
      subtitle: user.email ?? '',
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.tasks.withValues(alpha: 0.2),
        child: Text(
          (user.displayName?.isNotEmpty == true)
              ? user.displayName![0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: AppColors.tasks,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return _SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  String _themeModeLabel(BuildContext context) {
    final mode = sl<ThemeCubit>().state;
    return switch (mode) {
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
      ThemeMode.system => 'System',
    };
  }

  String _notificationStatusLabel() {
    final status = _notificationSettings?.authorizationStatus;
    return switch (status) {
      AuthorizationStatus.authorized => 'Enabled',
      AuthorizationStatus.denied => 'Denied - tap to enable in Settings',
      AuthorizationStatus.notDetermined => 'Tap to enable',
      AuthorizationStatus.provisional => 'Provisional',
      _ => 'Unknown',
    };
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildAiStatusBadge(String text, bool ok, Color tint) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok
            ? tint.withValues(alpha: 0.1)
            : AppColors.errorStatus.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok
              ? tint.withValues(alpha: 0.2)
              : AppColors.errorStatus.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 18,
            color: ok ? tint : AppColors.errorStatus,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ok ? context.textPri : AppColors.errorStatus,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: context.textSec,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 3),
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        leading: leading != null
            ? IconTheme(
                data: IconThemeData(color: context.textSec, size: 20),
                child: leading!,
              )
            : null,
        title: Text(
          title,
          style: TextStyle(
            color: context.textPri,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: context.textSec, fontSize: 12),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
