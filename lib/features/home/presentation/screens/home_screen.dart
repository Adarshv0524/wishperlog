import 'dart:async';

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
          title: savedNote.title ?? 'Note saved',
          category: savedNote.category ?? NoteCategory.general,
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
      body: GlassPageBackground(
        child: SafeArea(
          child: StreamBuilder<Map<NoteCategory, int>>(
            stream: _notes.watchActiveCountsLocal(),
            builder: (context, snapshot) {
              final counts =
                  snapshot.data ??
                  {for (final category in kAllNoteCategories) category: 0};

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Top Search Bar ─────────────────────────────────
                        GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: context.surface1,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: context.textSec.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: context.textSec,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Search notes...',
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.mic_none_rounded,
                                  color: context.textSec,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ── Branding & Menu ────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WishperLog',
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                                Text(
                                  'Jai Shree Ram',
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => context.push('/settings'),
                              style: IconButton.styleFrom(
                                backgroundColor: context.surface1,
                                padding: const EdgeInsets.all(10),
                              ),
                              icon: Icon(
                                Icons.tune_rounded,
                                size: 22,
                                color: context.textPri,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ThoughtCanvas(
                          controller: _writingController,
                          focusNode: _canvasFocusNode,
                          onSave: _saveWritingBox,
                          onMicPressStart: _startDictation,
                          onMicPressEnd: () =>
                              _stopDictation(submitCaptured: true),
                          isSaving: _saving,
                          isRecording: _isDictating,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      child: FolderGrid(counts: counts),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}