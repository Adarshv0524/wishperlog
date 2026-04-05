import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/capture/data/note_save_service.dart';
import 'package:wishperlog/features/home/presentation/widgets/folder_grid.dart';
import 'package:wishperlog/features/home/presentation/widgets/thought_canvas.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteRepository _notes = sl<NoteRepository>();
  late final NoteSaveService _saveService;
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _writingController = TextEditingController();
  final FocusNode _canvasFocusNode = FocusNode();

  bool _saving = false;
  bool _speechReady = false;
  bool _isDictating = false;
  String _dictationPrefix = '';

  @override
  void initState() {
    super.initState();
    _saveService = sl.isRegistered<NoteSaveService>()
        ? sl<NoteSaveService>()
        : NoteSaveService();
    _writingController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GlassPageBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalH = constraints.maxHeight;
              final folderH = totalH * 0.42;
              final topH = totalH - folderH;

              return StreamBuilder<Map<NoteCategory, int>>(
                stream: _notes.watchActiveCountsLocal(),
                builder: (context, snapshot) {
                  final counts = snapshot.data ?? {
                    for (final c in kAllNoteCategories) c: 0,
                  };

                  return Column(
                    children: [
                      // ── Top area: header + canvas ─────────────────────────
                      SizedBox(
                        height: topH,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Header row ─────────────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'WishperLog',
                                          style: TextStyle(
                                            color: context.textPri,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        Text(
                                          'Jai Shree Ram',
                                          style: TextStyle(
                                            color: context.textSec,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Search pill
                                  GestureDetector(
                                    onTap: () => context.push('/search'),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 16,
                                          sigmaY: 16,
                                        ),
                                        child: Container(
                                          height: 38,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                context.isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.10,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.52,
                                                      ),
                                                context.isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.04,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.30,
                                                      ),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: context.isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.18,
                                                    )
                                                  : Colors.black.withValues(
                                                      alpha: 0.06,
                                                    ),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: context.isDark
                                                    ? Colors.black.withValues(
                                                        alpha: 0.26,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.40,
                                                      ),
                                                blurRadius: 14,
                                                spreadRadius: -2,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.search_rounded,
                                                color: context.textSec,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Search',
                                                style: TextStyle(
                                                  color: context.textSec,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 16,
                                        sigmaY: 16,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                        child: InkWell(
                                          onTap: () => context.push('/settings'),
                                          borderRadius: BorderRadius.circular(14),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  context.isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.10,
                                                        )
                                                      : Colors.white.withValues(
                                                          alpha: 0.50,
                                                        ),
                                                  context.isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.04,
                                                        )
                                                      : Colors.white.withValues(
                                                          alpha: 0.28,
                                                        ),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: context.isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.18,
                                                      )
                                                    : Colors.black.withValues(
                                                        alpha: 0.06,
                                                      ),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: context.isDark
                                                      ? Colors.black.withValues(
                                                          alpha: 0.26,
                                                        )
                                                      : Colors.white.withValues(
                                                          alpha: 0.36,
                                                        ),
                                                  blurRadius: 14,
                                                  spreadRadius: -2,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Icon(
                                                Icons.tune_rounded,
                                                size: 20,
                                                color: context.textPri,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // ── Multifunctional canvas (fills remaining space) ──
                              Expanded(
                                child: ThoughtCanvas(
                                  controller: _writingController,
                                  focusNode: _canvasFocusNode,
                                  onSave: _saveWritingBox,
                                  onMicPressStart: _startDictation,
                                  onMicPressEnd: () =>
                                      _stopDictation(submitCaptured: true),
                                  isSaving: _saving,
                                  isRecording: _isDictating,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      // ── Bottom area: folder grid ───────────────────────────
                      SizedBox(
                        height: folderH,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: FolderGrid(counts: counts),
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
    );
  }
}