import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class TelegramScreen extends StatefulWidget {
  const TelegramScreen({super.key});

  @override
  State<TelegramScreen> createState() => _TelegramScreenState();
}

enum _Step { intro, waiting, success, error }

class _TelegramScreenState extends State<TelegramScreen> {
  final TelegramService _telegram = TelegramService();
  final UserRepository _users = sl<UserRepository>();

  _Step _step = _Step.intro;
  String? _resolvedChatId;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>?>? _chatIdSub;
  Timer? _timeoutTimer;
  bool _completed = false;

  @override
  void dispose() {
    _chatIdSub?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _startVerification() async {
    final botUsername = await _telegram.resolveBotUsername();
    if (botUsername == null || botUsername.isEmpty) {
      setState(() {
        _step = _Step.error;
        _errorMessage =
            'Telegram bot is not configured. Set TELEGRAM_BOT_TOKEN (and optionally TELEGRAM_BOT_USERNAME).';
      });
      return;
    }

    _chatIdSub?.cancel();
    _timeoutTimer?.cancel();

    final token = _randomToken();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    try {
      await _users.writePendingTelegramToken(token: token, expiresAt: expiresAt);
    } catch (e) {
      setState(() {
        _step = _Step.error;
        _errorMessage = 'Failed to prepare verification token: $e';
      });
      return;
    }

    setState(() {
      _step = _Step.waiting;
      _resolvedChatId = null;
      _errorMessage = null;
    });
    _completed = false;

    final ok = await launchUrl(
      Uri.parse('https://t.me/$botUsername?start=$token'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      await _users.clearPendingTelegramToken();
      if (!mounted) return;
      setState(() {
        _step = _Step.error;
        _errorMessage = 'Could not open Telegram. Please install Telegram and retry.';
      });
      return;
    }

    _chatIdSub = _users.watchCurrentUserDocument().listen((doc) async {
      if (_completed) return;
      final chatId = (doc?['telegram_chat_id'] ?? '').toString().trim();
      if (chatId.isEmpty) return;

      _completed = true;
      _chatIdSub?.cancel();
      _timeoutTimer?.cancel();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('telegram_chat_id', chatId);

      if (_telegram.isConfigured) {
        unawaited(
          _telegram.sendConnectionConfirmation(chatId: chatId),
        );
        unawaited(_telegram.registerDefaultCommands());
      }

      if (!mounted) return;
      setState(() {
        _step = _Step.success;
        _resolvedChatId = chatId;
      });
    });

    // Fallback path: useful when there is no backend webhook/service.
    unawaited(_pollTokenFallback(token));

    _timeoutTimer = Timer(const Duration(minutes: 10), () async {
      _chatIdSub?.cancel();
      await _users.clearPendingTelegramToken();
      if (!mounted) return;
      setState(() {
        _step = _Step.error;
        _errorMessage =
            'Link expired. Tap Retry and start again from Telegram.';
      });
    });
  }

  Future<void> _pollTokenFallback(String token) async {
    final chatId = await _telegram.resolveChatIdByStartToken(token: token);
    if (!mounted || _completed || chatId == null || chatId.isEmpty) return;

    try {
      await _users.updateTelegramChatId(chatId);
      await _users.clearPendingTelegramToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('telegram_chat_id', chatId);

      _completed = true;
      _chatIdSub?.cancel();
      _timeoutTimer?.cancel();

      if (_telegram.isConfigured) {
        unawaited(
          _telegram.sendConnectionConfirmation(chatId: chatId),
        );
        unawaited(_telegram.registerDefaultCommands());
      }

      if (!mounted) return;
      setState(() {
        _step = _Step.success;
        _resolvedChatId = chatId;
      });
    } catch (e) {
      if (!mounted || _completed) return;
      setState(() {
        _step = _Step.error;
        _errorMessage = 'Auto-link fallback failed: $e';
      });
    }
  }

  String _randomToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.telegram, size: 56, color: AppColors.tasks),
                    const SizedBox(height: 16),
                    Text(
                      'Connect Telegram',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get your daily note digest sent directly to Telegram.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSec, fontSize: 14, height: 1.45),
                    ),
                    const SizedBox(height: 32),
                    _buildStepContent(context),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(
                        _step == _Step.success ? 'Continue' : 'Skip for now',
                        style: TextStyle(color: context.textSec),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    return switch (_step) {
      _Step.intro => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassPane(
              level: 2,
              radius: 16,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepRow(number: '1', text: 'Open Telegram and search for your bot'),
                    const SizedBox(height: 10),
                    _StepRow(number: '2', text: 'Tap Connect to open Telegram deep link'),
                    const SizedBox(height: 10),
                    _StepRow(number: '3', text: 'In Telegram, tap START. We auto-link your chat.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tasks,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Connect in Telegram', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            if (AppEnv.telegramBotToken.trim().isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Bot not configured (TELEGRAM_BOT_TOKEN missing)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.textSec, fontSize: 12),
                ),
              ),
          ],
        ),
      _Step.waiting => Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'After Telegram opens, tap START to finish linking.',
              style: TextStyle(color: context.textSec, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This link expires in 10 minutes',
              style: TextStyle(color: context.textSec.withValues(alpha: 0.5), fontSize: 12),
            ),
          ],
        ),
      _Step.success => Column(
          children: [
            const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.followUp),
            const SizedBox(height: 12),
            Text(
              'Connected! Chat ID: $_resolvedChatId',
              style: TextStyle(color: context.textPri, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      _Step.error => Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.errorStatus),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: const TextStyle(color: AppColors.errorStatus),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _startVerification,
              child: const Text('Retry'),
            ),
          ],
        ),
    };
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.tasks.withValues(alpha: 0.15),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.tasks,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: context.textPri, fontSize: 13),
          ),
        ),
      ],
    );
  }
}