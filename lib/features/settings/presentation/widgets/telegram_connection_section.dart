// lib/features/settings/presentation/widgets/telegram_connection_section.dart
//
// Self-contained Telegram connection section for the Settings screen.
//
// Replaces the inline ad-hoc Telegram block in settings_screen.dart.
// Supports both the PRIMARY (auto deep-link) and SECONDARY (manual paste)
// methods with a compact guided UI appropriate for a settings context.
//
// Drop-in usage:
//   TelegramConnectionSection(
//     chatId: _telegramChatId,
//     connecting: _connectingTelegram,
//     onAutoConnect:   _startTelegramConnect,
//     onDisconnect:    _disconnectTelegram,
//     onCopyLink:      _copyTelegramLink,
//   )

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ─────────────────────────────────────────────────────────────────────────────

class TelegramConnectionSection extends StatefulWidget {
  const TelegramConnectionSection({
    super.key,
    this.chatId,
    this.connecting = false,
    required this.onAutoConnect,
    required this.onDisconnect,
    required this.onCopyLink,
    required this.onCancelWaiting,
  });

  /// The currently linked Telegram chat ID, or null if not connected.
  final String? chatId;

  /// True while the auto-connect flow is in-progress (waiting for bot reply).
  final bool connecting;

  final VoidCallback onAutoConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onCopyLink;
  final VoidCallback onCancelWaiting;

  @override
  State<TelegramConnectionSection> createState() =>
      _TelegramConnectionSectionState();
}

class _TelegramConnectionSectionState
    extends State<TelegramConnectionSection> {
  bool   _verifying  = false;
  String? _manualError;
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // ── Manual submit ──────────────────────────────────────────────────────────

  Future<void> _submitManualId() async {
    final raw = _idController.text.trim();
    if (raw.isEmpty) {
      setState(() => _manualError = 'Please enter your Chat ID.');
      return;
    }

    setState(() {
      _verifying   = true;
      _manualError = null;
    });

    try {
      await TelegramService.instance.linkManualChatId(raw);
      if (!mounted) return;
      setState(() {
        _verifying  = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telegram linked successfully!')),
      );
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() {
        _manualError = e.message;
        _verifying   = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _manualError = 'Could not save Chat ID: $e';
        _verifying   = false;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.chatId != null;

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tasks.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.telegram, color: AppColors.tasks, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Telegram',
                      style: TextStyle(
                        color: context.textPri,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      isConnected
                          ? 'Digest & bot commands active'
                          : 'Connect for daily digests',
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Connection status badge
              _StatusPill(connected: isConnected, pending: widget.connecting),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Connected state ────────────────────────────────────────────────
          if (isConnected) ...[
            _InfoRow(
              icon: Icons.tag_rounded,
              label: 'Chat ID',
              value: widget.chatId!,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _GlassButton(
                    icon: Icons.refresh_rounded,
                    label: 'Re-link',
                    color: AppColors.tasks,
                    filled: true,
                    onTap: widget.connecting ? null : widget.onAutoConnect,
                  ),
                ),
                const SizedBox(width: 8),
                _GlassButton(
                  icon: Icons.link_off_rounded,
                  label: 'Disconnect',
                  color: AppColors.reminders,
                  onTap: widget.onDisconnect,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _GlassButton(
                icon: Icons.content_copy_rounded,
                label: 'Copy link',
                color: AppColors.tasks,
                onTap: widget.onCopyLink,
              ),
            ),
          ]

          // ── Not connected + waiting ────────────────────────────────────────
          else if (widget.connecting) ...[
            GlassPane(
              level: 2,
              radius: 14,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.tasks),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Waiting — tap START in Telegram to finish linking…',
                      style: TextStyle(
                          color: context.textSec, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _GlassButton(
                    icon: Icons.content_copy_rounded,
                    label: 'Copy link',
                    color: AppColors.tasks,
                    onTap: widget.onCopyLink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GlassButton(
                    icon: Icons.cancel_rounded,
                    label: 'Cancel waiting',
                    color: AppColors.reminders,
                    onTap: widget.onCancelWaiting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ManualPanel(
              controller: _idController,
              errorText: _manualError,
              verifying: _verifying,
              onOpenBot: () async {
                try {
                  await TelegramService.instance.openTelegramBot();
                } catch (_) {}
              },
              onSubmit: _submitManualId,
              onCancel: () => setState(() {
                _manualError = null;
                _idController.clear();
              }),
            ),
          ]

          // ── Not connected, idle ────────────────────────────────────────────
          else ...[
            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: _GlassButton(
                icon: Icons.flash_on_rounded,
                label: 'Connect in Telegram  (Recommended)',
                color: AppColors.tasks,
                filled: true,
                onTap: widget.onAutoConnect,
              ),
            ),
            const SizedBox(height: 8),

            // Secondary actions row
            Row(
              children: [
                _GlassButton(
                  icon: Icons.content_copy_rounded,
                  label: 'Copy link',
                  color: AppColors.tasks,
                  onTap: widget.onCopyLink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GlassButton(
                    icon: Icons.keyboard_rounded,
                    label: 'Enter Chat ID manually',
                    color: AppColors.ideas,
                    onTap: () => setState(() {
                      _manualError = null;
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            _ManualPanel(
              controller: _idController,
              errorText: _manualError,
              verifying: _verifying,
              onOpenBot: () async {
                try {
                  await TelegramService.instance.openTelegramBot();
                } catch (_) {}
              },
              onSubmit: _submitManualId,
              onCancel: () => setState(() {
                _manualError = null;
                _idController.clear();
              }),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ManualPanel — always-visible "paste your chat_id" sub-form
// ─────────────────────────────────────────────────────────────────────────────

class _ManualPanel extends StatelessWidget {
  const _ManualPanel({
    required this.controller,
    this.errorText,
    required this.verifying,
    required this.onOpenBot,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool verifying;
  final VoidCallback onOpenBot;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 2,
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded,
                  size: 15, color: AppColors.ideas),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Manual Chat ID Link',
                  style: TextStyle(
                    color: context.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onCancel,
                child: Icon(Icons.close_rounded,
                    size: 18, color: context.textSec),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '1. Open the bot and tap /start — it will display your Chat ID.\n'
            '2. Copy that number and paste it below.',
            style: TextStyle(
                color: context.textSec, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: ButtonStyle(
              foregroundColor: const WidgetStatePropertyAll(AppColors.tasks),
              side: WidgetStatePropertyAll(
                BorderSide(color: AppColors.tasks.withValues(alpha: 0.30)),
              ),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              elevation: const WidgetStatePropertyAll(0),
            ),
            onPressed: onOpenBot,
            icon: const Icon(Icons.telegram, size: 16),
            label: const Text('Open bot',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            ],
            decoration: InputDecoration(
              labelText: 'Paste Chat ID',
              hintText: '123456789',
              errorText: errorText,
              prefixIcon: const Icon(Icons.tag_rounded, size: 18),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(AppColors.ideas),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 12)),
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              elevation: const WidgetStatePropertyAll(0),
            ),
            onPressed: verifying ? null : onSubmit,
            child: verifying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirm',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.connected, required this.pending});
  final bool connected;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    if (pending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppColors.ideas.withValues(alpha: 0.12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.ideas),
            ),
            const SizedBox(width: 5),
            Text('Pending',
                style: TextStyle(
                    color: AppColors.ideas,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    if (!connected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.followUp.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 12, color: AppColors.followUp),
          const SizedBox(width: 4),
          const Text('Connected',
              style: TextStyle(
                  color: AppColors.followUp,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.textSec),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(color: context.textSec, fontSize: 12)),
        Text(value,
            style: TextStyle(
                color: context.textPri,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String   label;
  final Color    color;
  final bool     filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? color.withValues(alpha: context.isDark ? 0.24 : 0.16)
        : context.surface1.withValues(alpha: 0.7);

    Widget content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bg,
          border: Border.all(
            color: color.withValues(alpha: filled ? 0.0 : 0.22),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    return content;
  }
}