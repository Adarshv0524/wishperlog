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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surface1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.tasks),
                const SizedBox(width: 8),
                Text(
                  'Quick Note',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.textPri,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 3,
              style: TextStyle(color: context.textPri, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: TextStyle(color: context.textSec),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.textPri.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.all(16),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tasks,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving 
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Save Note', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}