import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/notes/presentation/widgets/search_notes_modal.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
  with SingleTickerProviderStateMixin {
  final NoteRepository _notes = sl<NoteRepository>();
  final CaptureService _captureService = sl<CaptureService>();
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _writingController = TextEditingController();
  final FocusNode _canvasFocusNode = FocusNode();
  bool _saving = false;
  bool _speechReady = false;
  bool _isDictating = false;
  bool _isPressingMic = false;
  String _dictationPrefix = '';
  late final AnimationController _micGlowController;

  bool get _micHot => _isDictating || _isPressingMic;

  @override
  void initState() {
    super.initState();
    _micGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
  }

  @override
  void dispose() {
    _micGlowController.dispose();
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

    await HapticFeedback.mediumImpact();
    await _ensureSpeechReady();
    if (!_speechReady) {
      if (mounted) {
        setState(() {
          _isPressingMic = false;
        });
      }
      _micGlowController.stop();
      _micGlowController.value = 0;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech input is unavailable on this device.')),
      );
      return;
    }

    setState(() {
      _dictationPrefix = _writingController.text.trimRight();
    });

    try {
      await _speech.listen(
        onResult: _onDictationResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          autoPunctuation: false,
          onDevice: true,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isDictating = true;
      });
      _micGlowController.repeat(reverse: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isDictating = false;
        _isPressingMic = false;
      });
      _micGlowController.stop();
      _micGlowController.value = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech session could not start.')),
      );
    }
  }

  Future<void> _stopDictation({bool submitCaptured = false}) async {
    if (!_isDictating) {
      return;
    }
    try {
      await _speech.stop();
    } catch (_) {
      // Speech plugin can throw NotInitializedError on some devices/races.
    }

    if (submitCaptured) {
      final captured = _writingController.text.trim();
      if (captured.isNotEmpty) {
        try {
          await _captureService.ingestRawCapture(
            rawTranscript: captured,
            source: CaptureSource.homeWritingBox,
          );
        } catch (error, stackTrace) {
          debugPrint('[HomeScreen] Error saving dictated note: $error');
          debugPrintStack(stackTrace: stackTrace);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unable to save voice capture.')),
            );
          }
        }
        _writingController.clear();
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isDictating = false;
      _isPressingMic = false;
      _dictationPrefix = '';
    });
    _micGlowController.stop();
    _micGlowController.value = 0;
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveWritingBox() async {
    if (_saving) {
      return;
    }
    await _stopDictation(submitCaptured: false);
    setState(() {
      _saving = true;
    });

    await HapticFeedback.lightImpact();
    try {
      await _captureService.ingestRawCapture(
        rawTranscript: _writingController.text,
        source: CaptureSource.homeWritingBox,
      );
    } catch (error, stackTrace) {
      debugPrint('[HomeScreen] Error saving note: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save note.')),
        );
      }
    }
    _writingController.clear();

    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyText = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryText = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: StreamBuilder<Map<NoteCategory, int>>(
            stream: _notes.watchActiveCounts(),
            builder: (context, snapshot) {
              final counts =
                  snapshot.data ??
                  {for (final category in kAllNoteCategories) category: 0};

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, mode) {
                              final darkMode = mode == ThemeMode.dark;
                              return IconButton(
                                tooltip: darkMode
                                    ? 'Switch to light mode'
                                    : 'Switch to dark mode',
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  context.read<ThemeCubit>().toggleLightDark();
                                },
                                icon: Icon(
                                  darkMode
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  size: 20,
                                  color: bodyText,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Settings',
                            onPressed: () {
                              context.push('/settings');
                            },
                            icon: Icon(
                              Icons.settings_outlined,
                              size: 20,
                              color: bodyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    sliver: SliverToBoxAdapter(
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(999),
                        padding: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SearchNotesModal(),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 52,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 18,
                                    color: secondaryText,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Search notes',
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    sliver: SliverToBoxAdapter(
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(28),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.38,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Thought Canvas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: bodyText,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _saving ? null : _saveWritingBox,
                                    child: Text(
                                      _saving ? 'Saving...' : 'Save',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: GlassContainer(
                                  borderRadius: BorderRadius.circular(22),
                                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                  child: TextField(
                                    controller: _writingController,
                                    focusNode: _canvasFocusNode,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    minLines: 5,
                                    maxLines: null,
                                    expands: false,
                                    style: TextStyle(color: bodyText, height: 1.35),
                                    onChanged: (_) {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Write a thought, a plan, or a reminder...',
                                      hintStyle: TextStyle(color: secondaryText),
                                      border: InputBorder.none,
                                      isDense: true,
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  GestureDetector(
                                    onLongPressStart: (_) async {
                                      if (_isDictating) {
                                        return;
                                      }
                                      if (mounted) {
                                        setState(() {
                                          _isPressingMic = true;
                                        });
                                      }
                                      await _startDictation();
                                    },
                                    onLongPressEnd: (_) async {
                                      await _stopDictation(submitCaptured: true);
                                    },
                                    child: AnimatedBuilder(
                                      animation: _micGlowController,
                                      builder: (context, child) {
                                        final pulse = _micGlowController.value;
                                        final glowBlur = _micHot
                                            ? (18.0 + (pulse * 16.0))
                                            : 10.0;
                                        final glowSpread = _micHot
                                            ? (2.0 + (pulse * 3.0))
                                            : 0.0;

                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          curve: Curves.easeOutCubic,
                                          width: _micHot ? 48 : 44,
                                          height: _micHot ? 48 : 44,
                                          decoration: BoxDecoration(
                                            gradient: _micHot
                                                ? const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [Color(0xFF4C6FFF), Color(0xFF7B4BFF)],
                                                  )
                                                : null,
                                            color: _micHot ? null : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _micHot
                                                  ? const Color(0xFFD6DDFF)
                                                  : Colors.white.withValues(alpha: 0.55),
                                              width: _micHot ? 1.8 : 1.0,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _micHot
                                                    ? const Color(0xAA5F77FF)
                                                    : Colors.black.withValues(alpha: 0.20),
                                                blurRadius: glowBlur,
                                                spreadRadius: glowSpread,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _micHot ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                                            color: Colors.white,
                                            size: _micHot ? 22 : 20,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${_writingController.text.length} chars',
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Multiline canvas',
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final category = kAllNoteCategories[index];
                        final count = counts[category] ?? 0;

                        return GlassContainer(
                          borderRadius: BorderRadius.circular(18),
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              context.push('/folder', extra: category);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? Colors.white : Colors.black)
                                              .withValues(alpha: 0.22),
                                          blurRadius: 12,
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      categoryIcon(category),
                                      size: 18,
                                      color: bodyText,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        categoryLabel(category),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: bodyText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$count notes',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: secondaryText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: kAllNoteCategories.length),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 9,
                        crossAxisSpacing: 9,
                        childAspectRatio: 1.20,
                      ),
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
