import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class SearchNotesModal extends StatefulWidget {
  const SearchNotesModal({super.key});

  @override
  State<SearchNotesModal> createState() => _SearchNotesModalState();
}

class _SearchNotesModalState extends State<SearchNotesModal> {
  final NoteRepository _notes = sl<NoteRepository>();
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
    _queryController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _queryController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _notes.watchAllActive(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <Note>[];
          final query = _queryController.text.trim();

          final results = query.isEmpty ? all : _fuzzySearch(query, all);

          if (results.isEmpty) {
            return const Center(
              child: Text(
                'No matching notes',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            itemCount: results.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final note = results[index];
              return Material(
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/folder', extra: note.category);
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.cleanBody,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          categoryLabel(note.category),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Note> _fuzzySearch(String query, List<Note> notes) {
    final fuzzy = Fuzzy<Note>(
      notes,
      options: FuzzyOptions<Note>(
        threshold: 0.45,
        tokenize: true,
        keys: [
          WeightedKey<Note>(
            name: 'title',
            getter: (note) => note.title,
            weight: 2,
          ),
          WeightedKey<Note>(
            name: 'clean_body',
            getter: (note) => note.cleanBody,
            weight: 1,
          ),
        ],
      ),
    );

    return fuzzy.search(query).map((result) => result.item).toList();
  }
}
