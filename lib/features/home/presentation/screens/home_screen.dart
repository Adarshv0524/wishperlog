import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/capture/data/note_save_service.dart';
import 'package:wishperlog/features/home/presentation/widgets/folder_grid.dart';
import 'package:wishperlog/features/home/presentation/widgets/thought_canvas.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _overlayChannel = MethodChannel('wishperlog/overlay');

  final NoteRepository _notes = sl<NoteRepository>();
  late final NoteSaveService _saveService;
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _writingController = TextEditingController();
  final FocusNode _canvasFocusNode = FocusNode();

  bool _saving = false;
  bool _speechReady = false;
  bool _isDictating = false;
  String _dictationPrefix = '';
  late final Future<Uint8List?> _launcherIconBytesFuture;

  @override
  void initState() {
    super.initState();
    _saveService = sl.isRegistered<NoteSaveService>()
        ? sl<NoteSaveService>()
        : NoteSaveService();
    _launcherIconBytesFuture = _loadLauncherIconBytes();
    _writingController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<Uint8List?> _loadLauncherIconBytes() async {
    try {
      final bytes = await _overlayChannel.invokeMethod<Uint8List>('getLauncherIcon');
      return bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _canvasFocusNode.dispose();
    _writingController.dispose();
    super.dispose();
  }

  Future<void> _ensureSpeechReady() async {
    if (_speechReady) {
      return;
    }
    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _isDictating) {
          _stopDictation();
        }
      },
      onError: (_) {
        if (_isDictating) {
          _stopDictation();
        }
      },
      debugLogging: false,
    );
  }

  Future<void> _startDictation() async {
    if (_isDictating) {
      return;
    }
    await _ensureSpeechReady();
    if (!_speechReady) {
      return;
    }
    _dictationPrefix = _writingController.text.trimRight();

    await _speech.listen(
      onResult: _onDictationResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: false,
        onDevice: true,
      ),
    );

    if (mounted) {
      setState(() {
        _isDictating = true;
      });
    }
  }

  Future<void> _stopDictation({bool submitCaptured = false}) async {
    if (!_isDictating) {
      return;
    }
    await _speech.stop();

    if (submitCaptured) {
      await _saveWritingBox();
    }

    if (mounted) {
      setState(() {
        _isDictating = false;
      });
    }
  }

  void _onDictationResult(SpeechRecognitionResult result) {
    final spoken = result.recognizedWords.trim();
    final nextText = spoken.isEmpty
        ? _dictationPrefix
        : _dictationPrefix.isEmpty
        ? spoken
        : '$_dictationPrefix $spoken';

    _writingController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  Future<void> _saveWritingBox() async {
    if (_saving) {
      return;
    }

    final textToSave = _writingController.text.trim();
    if (textToSave.isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final savedNote = await _saveService.saveNote(
        rawTranscript: textToSave,
        source: CaptureSource.homeWritingBox,
        syncToCloud: true,
      );
      _writingController.clear();

      if (mounted) {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: savedNote.title,
          category: savedNote.category,
          model: savedNote.aiModel,
          noteId: savedNote.noteId,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppDurations.screenTransition,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: GlassPageBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalH = constraints.maxHeight;
                final folderH = totalH * 0.40;
                final topH = totalH - folderH;

                return StreamBuilder<Map<NoteCategory, int>>(
                  stream: _notes.watchActiveCountsLocal(),
                  builder: (context, snapshot) {
                    final counts = snapshot.data ?? {
                      for (final c in kAllNoteCategories) c: 0,
                    };
                    final activeTotal = counts.values.fold<int>(0, (sum, count) => sum + count);

                    return Column(
                      children: [
                        SizedBox(
                          height: topH,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassPane(
                                        level: 1,
                                        radius: 22,
                                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                                        tintOverride: context.isDark
                                            ? const Color(0x5F0F2742)
                                            : const Color(0xCBEAF4FF),
                                        child: Row(
                                          children: [
                                            FutureBuilder<Uint8List?>(
                                              future: _launcherIconBytesFuture,
                                              builder: (context, snapshot) {
                                                final iconBytes = snapshot.data;
                                                return Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [AppColors.tasks, Color(0xFF57C7FF)],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.tasks.withValues(alpha: 0.16),
                                                        blurRadius: 18,
                                                        spreadRadius: -4,
                                                        offset: const Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(6),
                                                    child: ClipOval(
                                                      child: iconBytes == null
                                                          ? const Icon(
                                                              Icons.auto_awesome_rounded,
                                                              size: 20,
                                                              color: Colors.white,
                                                            )
                                                          : Image.memory(
                                                              iconBytes,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'WishperLog',
                                                    style: TextStyle(
                                                      color: context.textPri,
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: -0.7,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Quick capture, cleaner folders, calmer settings.',
                                                    style: TextStyle(
                                                      color: context.textSec,
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            _GlassIconButton(
                                              icon: Icons.search_rounded,
                                              onTap: () => context.push('/search'),
                                            ),
                                            const SizedBox(width: 8),
                                            _GlassIconButton(
                                              icon: Icons.settings_rounded,
                                              onTap: () => context.push('/settings'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _HomeStatChip(
                                      icon: Icons.notes_rounded,
                                      label: '$activeTotal active',
                                      tint: AppColors.tasks,
                                    ),
                                    _HomeStatChip(
                                      icon: Icons.task_alt_rounded,
                                      label: '${counts[NoteCategory.tasks] ?? 0} tasks',
                                      tint: categoryColor(NoteCategory.tasks),
                                    ),
                                    _HomeStatChip(
                                      icon: Icons.notifications_active_outlined,
                                      label: '${counts[NoteCategory.reminders] ?? 0} reminders',
                                      tint: categoryColor(NoteCategory.reminders),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: RepaintBoundary(
                                    child: ThoughtCanvas(
                                      controller: _writingController,
                                      focusNode: _canvasFocusNode,
                                      onSave: _saveWritingBox,
                                      onSubmit: _saveWritingBox,
                                      onMicPressStart: _startDictation,
                                      onMicPressEnd: () => _stopDictation(submitCaptured: true),
                                      isSaving: _saving,
                                      isRecording: _isDictating,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: folderH,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: GlassPane(
                              level: 2,
                              radius: 26,
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              tintOverride: context.isDark
                                  ? const Color(0x4E122D4A)
                                  : const Color(0xA9EDF7FF),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Collections',
                                            style: TextStyle(
                                              color: context.textPri,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$activeTotal notes',
                                          style: TextStyle(
                                            color: context.textSec,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: RepaintBoundary(
                                      child: FolderGrid(counts: counts),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeStatChip extends StatelessWidget {
  const _HomeStatChip({required this.icon, required this.label, required this.tint});

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 3,
      radius: 999,
      tintOverride: tint.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.textPri,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDark
                      ? [
                          Colors.white.withValues(alpha: 0.16),
                          Colors.white.withValues(alpha: 0.06),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.76),
                          Colors.white.withValues(alpha: 0.46),
                        ],
                ),
                border: Border.all(
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.24)
                      : const Color(0x1A204268),
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark
                        ? Colors.black.withValues(alpha: 0.30)
                        : const Color(0x4F3D6A97),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 20, color: context.textPri),
              ),
            ),
          ),
        ),
      ),
    );
  }
}