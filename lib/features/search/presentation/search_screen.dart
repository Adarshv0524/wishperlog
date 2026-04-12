// lib/features/search/presentation/search_screen.dart
//
// Search screen refreshed with a clearer glass hierarchy:
// header, search field, filter rail, result cards, and empty states.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/search/data/smart_note_search.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  NoteCategory? _filterCategory;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  static const String _filterAll = 'All';
  static const List<(String, NoteCategory?)> _filterItems = <(String, NoteCategory?)>[
    (_filterAll, null),
    ('Tasks', NoteCategory.tasks),
    ('Reminders', NoteCategory.reminders),
    ('Ideas', NoteCategory.ideas),
    ('Follow-up', NoteCategory.followUp),
    ('Journal', NoteCategory.journal),
    ('General', NoteCategory.general),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _entryCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });

    _controller.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 180), () {
        if (mounted) {
          setState(() => _query = _controller.text.trim());
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  List<SearchHit> _applyFilter(List<SearchHit> hits) {
    if (_filterCategory == null) return hits;
    return hits.where((hit) => hit.note.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GlassPageBackground(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildFilterRail(),
                  const SizedBox(height: 6),
                  Expanded(child: _buildResults()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: GlassPane(
        level: 1,
        radius: 28,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            _RoundActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tint: AppColors.tasks,
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Search',
              style: TextStyle(
                color: context.textPri,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GlassPane(
        level: 2,
        radius: 26,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _RoundActionButton(
              icon: Icons.search_rounded,
              tint: AppColors.tasks,
              onTap: () => _focusNode.requestFocus(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  color: context.textPri,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Search notes, tasks, reminders...',
                  hintStyle: TextStyle(
                    color: context.textSec.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            if (_controller.text.isNotEmpty)
              _RoundActionButton(
                icon: Icons.close_rounded,
                tint: context.textSec,
                onTap: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassPane(
        level: 4,
        radius: 22,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filterItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (label, category) = _filterItems[index];
              final selected = _filterCategory == category;
              final chipColor = category != null ? categoryColor(category) : AppColors.tasks;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _filterCategory = category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? chipColor.withValues(alpha: context.isDark ? 0.22 : 0.18)
                        : context.surface1.withValues(alpha: 0.56),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? chipColor.withValues(alpha: 0.72)
                          : context.textSec.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? chipColor : context.textSec,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return StreamBuilder<List<Note>>(
      stream: sl<NoteRepository>().watchAllActive(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <Note>[];

        if (_query.isEmpty) {
          return _EmptyState(
            icon: Icons.manage_search_rounded,
            title: 'Start typing',
            subtitle: 'Search across notes, priorities, reminders, and AI-tagged captures.',
            tint: AppColors.tasks.withValues(alpha: 0.72),
            actions: [
              if (_filterCategory != null)
                _MiniActionPill(
                  label: 'Reset filter',
                  tint: categoryColor(_filterCategory!),
                  onTap: () => setState(() => _filterCategory = null),
                ),
            ],
          );
        }

        final hits = _applyFilter(SmartNoteSearch.searchSync(all, _query, limit: 60));

        if (hits.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No matching notes',
            subtitle: 'Try a broader term or remove the active filter.',
            tint: context.textSec.withValues(alpha: 0.42),
            actions: [
              _MiniActionPill(
                label: 'Clear search',
                tint: AppColors.tasks,
                onTap: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
              if (_filterCategory != null)
                _MiniActionPill(
                  label: 'Reset filter',
                  tint: categoryColor(_filterCategory!),
                  onTap: () => setState(() => _filterCategory = null),
                ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${hits.length} result${hits.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...hits.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: entry.key == hits.length - 1 ? 0 : 10),
                child: _SearchResultCard(
                  hit: entry.value,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                    context.push('/notes/${entry.value.note.noteId}');
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.hit, required this.onTap});

  final SearchHit hit;
  final VoidCallback onTap;

  Color _priorityColor(NotePriority p) => switch (p) {
        NotePriority.high => const Color(0xFFEF4444),
        NotePriority.medium => const Color(0xFFF59E0B),
        NotePriority.low => const Color(0xFF10B981),
      };

  @override
  Widget build(BuildContext context) {
    final note = hit.note;
    final accent = categoryColor(note.category);

    return GestureDetector(
      onTap: onTap,
      child: GlassPane(
        level: 2,
        radius: 22,
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: context.isDark ? 0.28 : 0.18),
                    accent.withValues(alpha: context.isDark ? 0.10 : 0.08),
                  ],
                ),
              ),
              child: Icon(categoryIcon(note.category), size: 20, color: accent),
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
                          note.title.isEmpty ? 'Untitled' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        hit.score.toStringAsFixed(1),
                        style: TextStyle(
                          color: context.textSec.withValues(alpha: 0.45),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (hit.snippet.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hit.snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Chip(label: categoryLabel(note.category), color: accent),
                      _Chip(
                        label: note.priority.name.toUpperCase(),
                        color: _priorityColor(note.priority),
                      ),
                      if (hit.matchedField.isNotEmpty && hit.matchedField != 'title')
                        _Chip(
                          label: hit.matchedField,
                          color: context.textSec.withValues(alpha: 0.62),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: context.isDark ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: GlassPane(
            level: 1,
            radius: 26,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tint.withValues(alpha: context.isDark ? 0.24 : 0.16),
                        tint.withValues(alpha: context.isDark ? 0.10 : 0.08),
                      ],
                    ),
                  ),
                  child: Icon(icon, size: 30, color: tint),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSec,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint.withValues(alpha: context.isDark ? 0.22 : 0.14),
              tint.withValues(alpha: context.isDark ? 0.10 : 0.08),
            ],
          ),
        ),
        child: Icon(icon, color: tint, size: 18),
      ),
    );
  }
}

class _MiniActionPill extends StatelessWidget {
  const _MiniActionPill({
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: tint.withValues(alpha: context.isDark ? 0.14 : 0.10),
          border: Border.all(color: tint.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: tint,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
