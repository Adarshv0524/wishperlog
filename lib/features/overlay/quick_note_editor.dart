import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class QuickNoteEditor extends StatefulWidget {
  const QuickNoteEditor({super.key});

  @override
  State<QuickNoteEditor> createState() => _QuickNoteEditorState();
}

class _QuickNoteEditorState extends State<QuickNoteEditor> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
      final text = _controller.text.trim();
      if (text.isEmpty) return;

      setState(() => _isSaving = true);
      try {
          final captureService = sl<CaptureService>();

          // Show processing state immediately on the Flutter island.
          try {
              sl<CaptureUiController>().notifyExternalRecordingProcessing(
                  provider: captureService.activeProviderName,
              );
          } catch (_) {}

          final saved = await captureService.ingestRawCapture(
              rawTranscript: text,
              source:        CaptureSource.textOverlay,
              syncToCloud:   true,
          );

          // Transition island to saved state.
          sl<CaptureUiController>().notifyExternalRecordingSaved(
              title:    saved?.title    ?? 'Quick note',
              category: saved?.category ?? NoteCategory.general,
              model:    saved?.aiModel,
              noteId:   saved?.noteId,
          );

          // Also update native island pill via OverlayNotifier.
          if (saved != null) {
              try {
                  await sl<OverlayNotifier>().notifyNativeSaved(
                      saved.title,
                      saved.category,
                    prefix: saveOriginPrefix(saved.aiModel),
                  );
              } catch (_) {}
          }

          if (mounted) context.pop();
      } catch (e) {
          // Reset both islands so neither stays stuck on "Classifying...".
          try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
          try {
              await sl<OverlayNotifier>().notifyNativeSaved(
                  'Error saving note',
                  NoteCategory.general,
                  prefix: 'sys',
              );
          } catch (_) {}
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to save quick note')),
              );
              setState(() => _isSaving = false);
          }
      }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassPane(
        level: 1,
        radius: 28,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.tasks.withValues(alpha: isDark ? 0.26 : 0.18),
                        AppColors.tasks.withValues(alpha: isDark ? 0.10 : 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.tasks.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(Icons.edit_note, color: AppColors.tasks, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Note',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.textPri,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Capture an idea in a neumorphic glass sheet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSec,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.close, color: context.textSec),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.surface1.withValues(alpha: isDark ? 0.76 : 0.88),
                    context.surface2.withValues(alpha: isDark ? 0.68 : 0.96),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.10),
                    blurRadius: 16,
                    offset: const Offset(5, 7),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.68),
                    blurRadius: 12,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 4,
                style: TextStyle(color: context.textPri, fontSize: 16, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  hintStyle: TextStyle(color: context.textSec),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isSaving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.tasks.withValues(alpha: isDark ? 0.96 : 0.92),
                      const Color(0xFF58D0C7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.14),
                      blurRadius: 16,
                      offset: const Offset(5, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.70),
                      blurRadius: 12,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSaving
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Note',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}