import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

/// Truecaller-style transparent overlay for quick text input.
/// The Dynamic Island (recording/saved state) is rendered globally in
/// OverlayRootWrapper and does NOT need a separate route.
class SystemBannerOverlay extends StatelessWidget {
  const SystemBannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Dismissible(
              key: const Key('truecaller_banner'),
              direction: DismissDirection.up,
              onDismissed: (_) => context.pop(),
              child: GlassPane(
                level: 2,
                radius: 24,
                padding: const EdgeInsets.all(0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: const QuickNoteEditor(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}