// lib/features/onboarding/presentation/screens/telegram_screen.dart
//
// v3.0 — Dual-Method Guided Connection Flow
//
// ┌─────────────────────────────────────────────────────┐
// │  Step-by-Step "Guided Connection" Screen             │
// │                                                      │
// │  1. Method Selection                                 │
// │       ● Primary  — Auto deep-link (recommended)      │
// │       ● Secondary — Manual chat-id paste (fallback)  │
// │                                                      │
// │  PRIMARY FLOW:                                       │
// │    loading → token → waiting → success | error       │
// │                                                      │
// │  SECONDARY FLOW:                                     │
// │    openBot → userCopiesChatId → pasteField           │
// │         → verify → success | error                   │
// └─────────────────────────────────────────────────────┘

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ── Internal state machine ────────────────────────────────────────────────────

enum _Method { unselected, primary, secondary }

enum _PrimaryStep { loading, token, waiting, success, error }

enum _SecondaryStep { instructions, verifying, success, error }

// ─────────────────────────────────────────────────────────────────────────────

class TelegramScreen extends StatefulWidget {
  const TelegramScreen({super.key});

  @override
  State<TelegramScreen> createState() => _TelegramScreenState();
}

class _TelegramScreenState extends State<TelegramScreen> {
  final TelegramService _telegram = TelegramService.instance;

  // ── Shared state ────────────────────────────────────────────────────────────
  _Method _method = _Method.unselected;

  String? _resolvedChatId;
  String? _errorMessage;
  bool    _busy = false;

  // ── Primary flow state ──────────────────────────────────────────────────────
  _PrimaryStep _primaryStep = _PrimaryStep.loading;
  String?      _token;
  bool         _tokenCopied = false;
  StreamSubscription<String?>? _chatIdSub;

  // ── Secondary flow state ────────────────────────────────────────────────────
  _SecondaryStep _secondaryStep = _SecondaryStep.instructions;
  final TextEditingController _chatIdController = TextEditingController();
  String?                     _secondaryError;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  @override
  void dispose() {
    _chatIdSub?.cancel();
    _chatIdController.dispose();
    super.dispose();
  }

  // ── Init — skip to success if already connected ──────────────────────────────

  Future<void> _checkExisting() async {
    try {
      final chatId = await _telegram.getLinkedChatId();
      if ((chatId ?? '').isNotEmpty && mounted) {
        setState(() {
          _method        = _Method.primary;
          _primaryStep   = _PrimaryStep.success;
          _resolvedChatId = chatId;
        });
      }
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIMARY FLOW LOGIC
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _startPrimaryFlow() async {
    setState(() {
      _method      = _Method.primary;
      _primaryStep = _PrimaryStep.loading;
      _errorMessage = null;
    });
    await _generateToken();
  }

  Future<void> _generateToken() async {
    if (!mounted) return;
    setState(() { _busy = true; _errorMessage = null; });

    try {
      final token = await _telegram.createTelegramConnectionToken();
      if (!mounted) return;
      setState(() {
        _token       = token;
        _primaryStep = _PrimaryStep.token;
        _busy        = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _primaryStep  = _PrimaryStep.error;
        _errorMessage = 'Could not generate a link code: $e';
        _busy         = false;
      });
    }
  }

  /// Opens Telegram app with the deep-link pre-filled, then starts watching
  /// Firestore for the bot to write back the chat_id.
  Future<void> _connectInTelegram() async {
    try {
      final token = _token ?? await _telegram.createTelegramConnectionToken();
      _token = token;
      await _telegram.connectTelegramAuto(existingToken: token);
      if (mounted) _startWatchingForChatId();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _primaryStep  = _PrimaryStep.error;
        _errorMessage = 'Could not open Telegram: $e';
      });
    }
  }

  void _startWatchingForChatId() {
    _chatIdSub?.cancel();
    setState(() => _primaryStep = _PrimaryStep.waiting);

    _chatIdSub = _telegram.watchLinkedChatId().listen((chatId) {
      final trimmed = (chatId ?? '').trim();
      if (trimmed.isEmpty || !mounted) return;
      setState(() {
        _primaryStep    = _PrimaryStep.success;
        _resolvedChatId = trimmed;
        _token          = null;
      });
      _chatIdSub?.cancel();
    });
  }

  Future<void> _copyLink() async {
    final token = _token ?? _telegram.lastLinkToken;
    if (token == null) return;
    final link = await _telegram.buildTelegramStartUri(token);
    await Clipboard.setData(ClipboardData(text: link.toString()));
    if (!mounted) return;
    setState(() => _tokenCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _tokenCopied = false);
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECONDARY FLOW LOGIC
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _startSecondaryFlow() async {
    setState(() {
      _method        = _Method.secondary;
      _secondaryStep = _SecondaryStep.instructions;
      _secondaryError = null;
    });
  }

  Future<void> _openBotForSecondary() async {
    try {
      await _telegram.openTelegramBot();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Telegram: $e')),
        );
      }
    }
  }

  Future<void> _submitManualChatId() async {
    final raw = _chatIdController.text.trim();
    if (raw.isEmpty) {
      setState(() => _secondaryError = 'Please paste your Chat ID first.');
      return;
    }

    setState(() {
      _secondaryStep  = _SecondaryStep.verifying;
      _secondaryError = null;
      _busy = true;
    });

    try {
      final chatId = await _telegram.linkManualChatId(raw);
      if (!mounted) return;
      setState(() {
        _secondaryStep  = _SecondaryStep.success;
        _resolvedChatId = chatId;
        _busy = false;
      });
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() {
        _secondaryStep  = _SecondaryStep.instructions;
        _secondaryError = e.message;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _secondaryStep  = _SecondaryStep.error;
        _secondaryError = 'Could not save Chat ID: $e';
        _busy = false;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED — DISCONNECT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    _chatIdSub?.cancel();
    try {
      await _telegram.disconnectTelegram();
      if (!mounted) return;
      _chatIdController.clear();
      setState(() {
        _method        = _Method.unselected;
        _primaryStep   = _PrimaryStep.loading;
        _secondaryStep = _SecondaryStep.instructions;
        _resolvedChatId = null;
        _token         = null;
        _errorMessage  = null;
        _secondaryError = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not disconnect: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  String get _botUsername {
    final configured = AppEnv.telegramBotUsername.trim();
    return configured.isNotEmpty ? '@${configured.replaceFirst(RegExp(r'^@+'), '')}' : '@WishperLogDigestBot';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom title bar ────────────────────────────────────────────
              _buildTitleBar(context),

              // ── Scrollable content ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step indicator (breadcrumb)
                      _buildStepIndicator(),
                      const SizedBox(height: 16),

                      // Main card
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 340),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _buildCurrentCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: GlassContainer(
              borderRadius: BorderRadius.circular(14),
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: context.textPri),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telegram',
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Connect your bot for digest & commands',
                  style: TextStyle(
                    color: context.textSec,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          if (_resolvedChatId != null)
            _StatusBadge(connected: true)
          else if (_method != _Method.unselected)
            _StatusBadge(connected: false),
        ],
      ),
    );
  }

  // ── Step indicator / breadcrumb ────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final steps = _buildStepLabels();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
        ),
        itemBuilder: (context, index) {
          final (label, active) = steps[index];
          return _StepChip(label: label, active: active);
        },
      ),
    );
  }

  List<(String, bool)> _buildStepLabels() {
    if (_method == _Method.unselected) {
      return [('Choose method', true)];
    }
    if (_method == _Method.primary) {
      return [
        ('Choose method', false),
        ('Auto-connect', _primaryStep == _PrimaryStep.token),
        ('Verify', _primaryStep == _PrimaryStep.waiting),
        ('Done', _primaryStep == _PrimaryStep.success),
      ];
    }
    // Secondary
    return [
      ('Choose method', false),
      ('Open bot', _secondaryStep == _SecondaryStep.instructions),
      ('Paste ID', _secondaryStep == _SecondaryStep.instructions),
      ('Done', _secondaryStep == _SecondaryStep.success),
    ];
  }

  // ── Main card switcher ─────────────────────────────────────────────────────

  Widget _buildCurrentCard() {
    // Universal success state
    if (_resolvedChatId != null) {
      return _SuccessCard(
        key: const ValueKey('success'),
        chatId: _resolvedChatId!,
        onContinue: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        onDisconnect: _disconnect,
        busy: _busy,
      );
    }

    // Method selection
    if (_method == _Method.unselected) {
      return _MethodSelectionCard(
        key: const ValueKey('method'),
        botUsername: _botUsername,
        onPrimary:   _startPrimaryFlow,
        onSecondary: _startSecondaryFlow,
      );
    }

    // Primary flow
    if (_method == _Method.primary) {
      return switch (_primaryStep) {
        _PrimaryStep.loading => _LoadingCard(key: const ValueKey('p-loading')),
        _PrimaryStep.token => _PrimaryTokenCard(
            key: const ValueKey('p-token'),
            token: _token ?? '',
            botUsername: _botUsername,
            tokenCopied: _tokenCopied,
            busy: _busy,
            onConnect: _connectInTelegram,
            onCopy: _copyLink,
            onSwitchMethod: _startSecondaryFlow,
          ),
        _PrimaryStep.waiting => _WaitingCard(
            key: const ValueKey('p-waiting'),
            botUsername: _botUsername,
          ),
        _PrimaryStep.success => const SizedBox.shrink(),
        _PrimaryStep.error => _ErrorCard(
            key: const ValueKey('p-error'),
            message: _errorMessage ?? 'An unexpected error occurred.',
            onRetry: _generateToken,
          ),
      };
    }

    // Secondary flow
    return switch (_secondaryStep) {
      _SecondaryStep.instructions => _SecondaryInstructionsCard(
          key: const ValueKey('s-instructions'),
          botUsername: _botUsername,
          controller: _chatIdController,
          errorText: _secondaryError,
          busy: _busy,
          onOpenBot: _openBotForSecondary,
          onSubmit: _submitManualChatId,
          onSwitchMethod: _startPrimaryFlow,
        ),
      _SecondaryStep.verifying => _LoadingCard(
          key: const ValueKey('s-verifying'),
          message: 'Saving your Chat ID…',
        ),
      _SecondaryStep.success => const SizedBox.shrink(),
      _SecondaryStep.error => _ErrorCard(
          key: const ValueKey('s-error'),
          message: _secondaryError ?? 'An unexpected error occurred.',
          onRetry: _startSecondaryFlow,
        ),
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARD WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ── Method selection ──────────────────────────────────────────────────────────

class _MethodSelectionCard extends StatelessWidget {
  const _MethodSelectionCard({
    super.key,
    required this.botUsername,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String botUsername;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon + header
          const Icon(Icons.telegram, size: 52, color: AppColors.tasks),
          const SizedBox(height: 14),
          Text(
            'Connect Telegram',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textPri,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Receive daily digests and query your notes directly from $botUsername.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 28),

          // ── Primary method card ────────────────────────────────────────────
          _MethodOption(
            icon: Icons.flash_on_rounded,
            iconColor: AppColors.tasks,
            title: 'Auto-connect  (Recommended)',
            description: 'Tap once — the app opens Telegram with everything '
                'pre-filled. The link happens automatically.',
            badge: 'INSTANT',
            badgeColor: AppColors.tasks,
            onTap: onPrimary,
          ),

          const SizedBox(height: 12),

          // ── Secondary method card ──────────────────────────────────────────
          _MethodOption(
            icon: Icons.content_paste_rounded,
            iconColor: AppColors.ideas,
            title: 'Manual paste  (Fallback)',
            description: 'Open $botUsername in Telegram. It will display your '
                'Chat ID. Copy and paste it back here.',
            badge: 'MANUAL',
            badgeColor: AppColors.ideas,
            onTap: onSecondary,
          ),
        ],
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  final IconData  icon;
  final Color     iconColor;
  final String    title;
  final String    description;
  final String    badge;
  final Color     badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: context.textPri,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: badgeColor.withValues(alpha: 0.12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                        color: context.textSec, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: context.textSec.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Primary: token display ────────────────────────────────────────────────────

class _PrimaryTokenCard extends StatelessWidget {
  const _PrimaryTokenCard({
    super.key,
    required this.token,
    required this.botUsername,
    required this.tokenCopied,
    required this.busy,
    required this.onConnect,
    required this.onCopy,
    required this.onSwitchMethod,
  });

  final String token;
  final String botUsername;
  final bool   tokenCopied;
  final bool   busy;
  final VoidCallback onConnect;
  final VoidCallback onCopy;
  final VoidCallback onSwitchMethod;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step number badge
          _StepBadge(label: 'STEP 1 OF 2', color: AppColors.tasks),
          const SizedBox(height: 16),
          Text(
            'Open Telegram',
            style: TextStyle(
                color: context.textPri,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below. The Telegram app will open with a '
            'pre-filled message — just tap START and the link completes automatically.',
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),

          // Connect button
          FilledButton.icon(
            style: _filledStyle(AppColors.tasks),
            onPressed: busy ? null : onConnect,
            icon: const Icon(Icons.telegram, size: 18),
            label: const Text('Open Telegram & Connect'),
          ),
          const SizedBox(height: 12),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or',
                    style: TextStyle(
                        color: context.textSec.withValues(alpha: 0.5),
                        fontSize: 12)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),

          // Copy link (for users whose deep-link doesn't work)
          OutlinedButton.icon(
            style: _outlinedStyle(context, AppColors.tasks),
            onPressed: onCopy,
            icon: Icon(
              tokenCopied
                  ? Icons.check_circle_rounded
                  : Icons.content_copy_rounded,
              size: 16,
            ),
            label: Text(tokenCopied ? 'Copied!' : 'Copy link instead'),
          ),
          const SizedBox(height: 20),

          _InfoBox(
            icon: Icons.info_outline_rounded,
            text: 'After tapping START in Telegram, return here. '
                'This screen will update automatically when the link is confirmed.',
          ),
          const SizedBox(height: 16),

          // Escape hatch → secondary method
          Center(
            child: TextButton(
              onPressed: onSwitchMethod,
              child: Text(
                'Having trouble? Use manual Chat ID instead',
                style: TextStyle(
                    color: context.textSec, fontSize: 12, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Primary: waiting ──────────────────────────────────────────────────────────

class _WaitingCard extends StatelessWidget {
  const _WaitingCard({super.key, required this.botUsername});
  final String botUsername;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.tasks,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Waiting for Telegram…',
            style: TextStyle(
              color: context.textPri,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open $botUsername and tap START. This page will update automatically when confirmed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),
          _InfoBox(
            icon: Icons.lock_outline_rounded,
            text: 'WishperLog never posts to Telegram without your permission.',
          ),
        ],
      ),
    );
  }
}

// ── Secondary: instructions + paste field ─────────────────────────────────────

class _SecondaryInstructionsCard extends StatelessWidget {
  const _SecondaryInstructionsCard({
    super.key,
    required this.botUsername,
    required this.controller,
    this.errorText,
    required this.busy,
    required this.onOpenBot,
    required this.onSubmit,
    required this.onSwitchMethod,
  });

  final String botUsername;
  final TextEditingController controller;
  final String? errorText;
  final bool busy;
  final VoidCallback onOpenBot;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchMethod;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepBadge(label: 'MANUAL FALLBACK', color: AppColors.ideas),
          const SizedBox(height: 16),
          Text(
            'Get your Chat ID',
            style: TextStyle(
                color: context.textPri,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          // Numbered instructions
          _NumberedStep(
            number: 1,
            text: 'Tap the button below to open $botUsername.',
          ),
          const SizedBox(height: 8),
          _NumberedStep(
            number: 2,
            text: 'The bot will reply with your unique Chat ID (a number).',
          ),
          const SizedBox(height: 8),
          _NumberedStep(
            number: 3,
            text: 'Copy that number and paste it in the field below.',
          ),
          const SizedBox(height: 20),

          // Open bot button
          OutlinedButton.icon(
            style: _outlinedStyle(context, AppColors.tasks),
            onPressed: onOpenBot,
            icon: const Icon(Icons.telegram, size: 18),
            label: Text('Open $botUsername'),
          ),
          const SizedBox(height: 20),

          // Chat ID field
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            ],
            decoration: InputDecoration(
              labelText: 'Paste your Chat ID here',
              hintText: 'e.g. 123456789',
              errorText: errorText,
              prefixIcon: const Icon(Icons.tag_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton(
            style: _filledStyle(AppColors.ideas),
            onPressed: busy ? null : onSubmit,
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirm Chat ID'),
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: onSwitchMethod,
              child: Text(
                'Switch to auto-connect instead',
                style:
                    TextStyle(color: context.textSec, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success ───────────────────────────────────────────────────────────────────

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    super.key,
    required this.chatId,
    required this.onContinue,
    required this.onDisconnect,
    required this.busy,
  });

  final String chatId;
  final VoidCallback onContinue;
  final VoidCallback onDisconnect;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.followUp.withValues(alpha: 0.14),
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.followUp, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Telegram Connected!',
            style: TextStyle(
              color: context.textPri,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your digest messages will be sent to this chat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 18),
          GlassContainer(
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tag_rounded, size: 16, color: AppColors.tasks),
                const SizedBox(width: 8),
                Text(
                  'Chat ID: $chatId',
                  style: TextStyle(
                    color: context.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: _filledStyle(AppColors.tasks),
              onPressed: onContinue,
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor:
                    WidgetStatePropertyAll(AppColors.reminders),
                side: WidgetStatePropertyAll(
                  BorderSide(
                      color: AppColors.reminders.withValues(alpha: 0.4)),
                ),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
              onPressed: busy ? null : onDisconnect,
              child: const Text('Disconnect Telegram'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({super.key, this.message = 'Loading…'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.tasks),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: context.textSec, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.reminders),
          const SizedBox(height: 14),
          Text(
            'Something went wrong',
            style: TextStyle(
                color: context.textPri,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.textSec, fontSize: 13, height: 1.45)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: _filledStyle(AppColors.tasks),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SMALL HELPER WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.connected});
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color  = connected ? AppColors.followUp : AppColors.ideas;
    final icon   = connected ? Icons.check_circle_rounded : Icons.pending_rounded;
    final label  = connected ? 'Connected' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active
            ? AppColors.tasks.withValues(alpha: 0.15)
            : context.surface1.withValues(alpha: 0.4),
        border: Border.all(
          color: active
              ? AppColors.tasks.withValues(alpha: 0.35)
              : context.textSec.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.tasks : context.textSec,
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: 0.12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});
  final int    number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ideas.withValues(alpha: 0.14),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.ideas,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: TextStyle(
                  color: context.textSec, fontSize: 13, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});
  final IconData icon;
  final String   text;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.textSec),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: context.textSec, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Button styles (module-level helpers) ──────────────────────────────────────

ButtonStyle _filledStyle(Color color) => ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(color),
  foregroundColor: const WidgetStatePropertyAll(Colors.white),
  padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
  shape: const WidgetStatePropertyAll(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  elevation: const WidgetStatePropertyAll(0),
  textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
);

ButtonStyle _outlinedStyle(BuildContext context, Color color) => ButtonStyle(
  foregroundColor: WidgetStatePropertyAll(color),
  backgroundColor: WidgetStatePropertyAll(color.withValues(alpha: 0.06)),
  side: WidgetStatePropertyAll(
      BorderSide(color: color.withValues(alpha: 0.35))),
  padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 20, vertical: 13)),
  shape: const WidgetStatePropertyAll(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  elevation: const WidgetStatePropertyAll(0),
  textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
);