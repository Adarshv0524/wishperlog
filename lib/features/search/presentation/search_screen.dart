// lib/features/search/presentation/search_screen.dart
//
// God-Level Search 2.0
//  • Full-screen immersive entry with hero animation
//  • Fuzzy matching via SmartNoteSearch
//  • Filter chips: All | Tasks | Reminders | Ideas | Follow-up | Journal
//  • Empty-state illustrations
//  • Highlighted match snippets
//  • Priority badges

import 'dart:async';
import 'dart:ui';

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
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();
  Timer? _debounce;

  String _query = '';
  NoteCategory? _filterCategory; // null = All

  late final AnimationController _entryCtrl;
  late final Animation<double>    _entryFade;
  late final Animation<Offset>    _entrySlide;

  static const _filterAll = 'All';

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _entryCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _controller.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 180), () {
        if (mounted) setState(() => _query = _controller.text.trim());
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
    return hits.where((h) => h.note.category == _filterCategory).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Frosted backdrop ─────────────────────────────────────────────
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: context.isDark
                  ? const Color(0xE8090E1A)
                  : const Color(0xE8F0F4FF),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          FadeTransition(
            opacity: _entryFade,
            child: SlideTransition(
              position: _entrySlide,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildFilterChips(),
                    const Divider(height: 1, thickness: 0.5),
                    Expanded(child: _buildResults()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: context.surface1.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: context.textPri,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text field
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: context.surface1.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.tasks.withValues(alpha: 0.6)
                      : context.textSec.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, size: 20, color: context.textSec),
                  const SizedBox(width: 8),
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
                        hintText: 'Search notes, tasks, ideas…',
                        hintStyle: TextStyle(
                          color: context.textSec.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (_) {},
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: context.textSec,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  static const _filterItems = <(String, NoteCategory?)>[
    (_filterAll, null),
    ('Tasks', NoteCategory.tasks),
    ('Reminders', NoteCategory.reminders),
    ('Ideas', NoteCategory.ideas),
    ('Follow-up', NoteCategory.followUp),
    ('Journal', NoteCategory.journal),
    ('General', NoteCategory.general),
  ];

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterItems.length,
        separatorBuilder: (context, separatorIndex) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, cat) = _filterItems[i];
          final selected = _filterCategory == cat;
          final chipColor = cat != null ? categoryColor(cat) : AppColors.tasks;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filterCategory = cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? chipColor.withValues(alpha: 0.18)
                    : context.surface1.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? chipColor.withValues(alpha: 0.8)
                      : context.textSec.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? chipColor : context.textSec,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────

  Widget _buildResults() {
    return StreamBuilder<List<Note>>(
      stream: sl<NoteRepository>().watchAllActive(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <Note>[];

        // Empty state — no query yet
        if (_query.isEmpty) {
          return _EmptyState(
            icon: Icons.auto_awesome_rounded,
            title: 'Search everything',
            subtitle: 'Find notes, tasks, reminders, and ideas instantly.',
            tint: AppColors.tasks.withValues(alpha: 0.7),
          );
        }

        final rawHits = SmartNoteSearch.searchSync(all, _query, limit: 60);
        final hits = _applyFilter(rawHits);

        // No results
        if (hits.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No results',
            subtitle: 'Try a different keyword or remove filters.',
            tint: context.textSec.withValues(alpha: 0.4),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          itemCount: hits.length,
          separatorBuilder: (context, separatorIndex) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _SearchResultCard(
            hit: hits[i],
            query: _query,
            onTap: () {
              HapticFeedback.selectionClick();
              context.pop();
              context.push('/notes/${hits[i].note.noteId}');
            },
          ),
        );
      },
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.hit,
    required this.query,
    required this.onTap,
  });

  final SearchHit hit;
  final String query;
  final VoidCallback onTap;

  Color _priorityColor(NotePriority p) => switch (p) {
    NotePriority.high   => const Color(0xFFEF4444),
    NotePriority.medium => const Color(0xFFF59E0B),
    NotePriority.low    => const Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final note = hit.note;
    final accent = categoryColor(note.category);

    return GestureDetector(
      onTap: onTap,
      child: GlassPane(
        level: 2,
        radius: 18,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                categoryIcon(note.category),
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (hit.snippet.isNotEmpty) ...[
                    const SizedBox(height: 4),
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
                  const SizedBox(height: 8),
                  // Chips row
                  Wrap(
                    spacing: 6,
                    children: [
                      _Chip(
                        label: categoryLabel(note.category),
                        color: accent,
                      ),
                      _Chip(
                        label: note.priority.name.toUpperCase(),
                        color: _priorityColor(note.priority),
                      ),
                      if (hit.matchedField.isNotEmpty && hit.matchedField != 'title')
                        _Chip(
                          label: hit.matchedField,
                          color: context.textSec.withValues(alpha: 0.6),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Score
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                hit.score.toStringAsFixed(1),
                style: TextStyle(
                  color: context.textSec.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    ),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: tint),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: context.textPri,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSec,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}