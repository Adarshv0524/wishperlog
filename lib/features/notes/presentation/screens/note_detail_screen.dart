import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context) {
    final notes = sl<NoteRepository>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassTitleBar(
        title: 'Note',
        subtitle: 'Detail view',
        onBack: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      body: GlassPageBackground(
        child: StreamBuilder<Note?>(
          stream: notes.watchNoteById(noteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final note = snapshot.data;
            if (note == null) {
              return const Center(
                child: Text('Note not found or no longer available.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(label: categoryLabel(note.category)),
                      _MetaChip(label: note.priority.name.toUpperCase()),
                      _MetaChip(label: note.source.name),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note.cleanBody,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Captured: ${note.createdAt}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
