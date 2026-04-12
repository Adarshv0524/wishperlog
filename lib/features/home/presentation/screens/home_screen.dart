import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/app/route_observer.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/home/presentation/widgets/folder_grid.dart';
import 'package:wishperlog/features/home/presentation/widgets/thought_canvas.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  static const MethodChannel _overlayChannel = MethodChannel('wishperlog/overlay');

  final NoteRepository _notes = sl<NoteRepository>();
  late final CaptureService _captureService;
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _writingController = TextEditingController();
  final FocusNode _canvasFocusNode = FocusNode();

  bool _saving = false;
  bool _speechReady = false;
  bool _isDictating = false;
  String _dictationPrefix = '';
  NoteCategory _quickCategory = NoteCategory.general;
  NotePriority _quickPriority = NotePriority.medium;
  DateTime? _quickReminderAt;
  late final Future<Uint8List?> _launcherIconBytesFuture;

  @override
  void initState() {
    super.initState();
    _captureService = sl.isRegistered<CaptureService>()
        ? sl<CaptureService>()
        : CaptureService();
    _launcherIconBytesFuture = _loadLauncherIconBytes();
    _writingController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.unsubscribe(this);
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _canvasFocusNode.dispose();
    _writingController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    _clearCanvasFocus();
  }

  @override
  void didPopNext() {
    _clearCanvasFocus();
  }

  void _clearCanvasFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    _canvasFocusNode.unfocus();
  }

  Future<Uint8List?> _loadLauncherIconBytes() async {
    try {
      final bytes = await _overlayChannel.invokeMethod<Uint8List>('getLauncherIcon');
      return bytes;
    } catch (_) {
      return null;
    }
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
      final savedNote = await _captureService.ingestRawCapture(
        rawTranscript: textToSave,
        source: CaptureSource.homeWritingBox,
        syncToCloud: true,
        categoryOverride: _quickCategory,
        priorityOverride: _quickPriority,
        extractedDateOverride: _quickReminderAt,
      );
      if (savedNote == null) {
        return;
      }
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

  Future<void> _openCaptureMetadataSheet() async {
    var category = _quickCategory;
    var priority = _quickPriority;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: GlassPane(
                    level: 1,
                    radius: 26,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: StatefulBuilder(
              builder: (context, setSheetState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Capture class',
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set the default category and priority for the next save.',
                    style: TextStyle(color: context.textSec, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kAllNoteCategories.map((entry) {
                      final isSelected = entry == category;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(categoryLabel(entry)),
                        onSelected: (_) => setSheetState(() => category = entry),
                        selectedColor: categoryColor(entry).withValues(alpha: 0.16),
                        checkmarkColor: categoryColor(entry),
                        labelStyle: TextStyle(
                          color: isSelected ? categoryColor(entry) : context.textPri,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Priority',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<NotePriority>(
                    segments: const [
                      ButtonSegment(value: NotePriority.high, label: Text('High')),
                      ButtonSegment(value: NotePriority.medium, label: Text('Medium')),
                      ButtonSegment(value: NotePriority.low, label: Text('Low')),
                    ],
                    selected: {priority},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      setSheetState(() => priority = selection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.tasks,
                      selectedForegroundColor: Colors.white,
                      backgroundColor: context.surface1,
                      foregroundColor: context.textPri,
                      side: BorderSide(color: context.textSec.withValues(alpha: 0.10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setSheetState(() {
                          category = NoteCategory.general;
                          priority = NotePriority.medium;
                        });
                      },
                      child: const Text('Reset to default'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _quickCategory = category;
      _quickPriority = priority;
    });
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _quickReminderAt ?? DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _quickReminderAt == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(_quickReminderAt!),
    );
    if (time == null || !mounted) return;

    setState(() {
      _quickReminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_quickCategory == NoteCategory.general) {
        _quickCategory = NoteCategory.reminders;
      }
    });
  }

  void _clearReminder() {
    setState(() => _quickReminderAt = null);
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

                    final tagActive = _quickCategory != NoteCategory.general ||
                        _quickPriority != NotePriority.medium;
                    final tagLabel = tagActive
                        ? '${categoryLabel(_quickCategory)} • ${_quickPriority.name.toUpperCase()}'
                        : null;
                    final reminderLabel = _quickReminderAt != null
                        ? '${MaterialLocalizations.of(context).formatMediumDate(_quickReminderAt!)} • ${TimeOfDay.fromDateTime(_quickReminderAt!).format(context)}'
                        : null;

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
                                              radius: 24,
                                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                                                        color: AppColors.tasks.withValues(alpha: 0.12),
                                                        blurRadius: 16,
                                                        spreadRadius: -4,
                                                        offset: const Offset(0, 5),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: ClipOval(
                                                      child: iconBytes == null
                                                          ? const Icon(
                                                              Icons.auto_awesome_rounded,
                                                              size: 19,
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
                                                      fontSize: 21,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: -0.55,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Quick capture, cleaner folders, calmer settings.',
                                                    style: TextStyle(
                                                      color: context.textSec.withValues(alpha: 0.88),
                                                      fontSize: 11.2,
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
                                      onTagTap: _openCaptureMetadataSheet,
                                      onReminderTap: _pickReminder,
                                      onReminderLongPress: _clearReminder,
                                      onMicPressStart: _startDictation,
                                      onMicPressEnd: () => _stopDictation(submitCaptured: true),
                                      isSaving: _saving,
                                      isRecording: _isDictating,
                                      tagActive: tagActive,
                                      reminderActive: _quickReminderAt != null,
                                      tagLabel: tagLabel,
                                      reminderLabel: reminderLabel,
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
                                radius: 28,
                                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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