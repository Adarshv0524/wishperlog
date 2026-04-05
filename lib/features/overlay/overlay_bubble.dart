import 'package:flutter/material.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';

/// The root wrapper placed inside MaterialApp.builder.
/// Renders all routes as normal and bridges native overlay callbacks.
class OverlayRootWrapper extends StatefulWidget {
  const OverlayRootWrapper({required this.child, super.key});

  final Widget child;

  @override
  State<OverlayRootWrapper> createState() => _OverlayRootWrapperState();
}

class _OverlayRootWrapperState extends State<OverlayRootWrapper> {
  late final OverlayNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = sl<OverlayNotifier>();
    _notifier.addOpenEditorListener(_onNativeEditorCall);
    // Hydrate after the first frame so prefs are read after widget tree is up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.hydrate();
    });
  }

  @override
  void dispose() {
    _notifier.removeOpenEditorListener(_onNativeEditorCall);
    super.dispose();
  }

  void _onNativeEditorCall() {
    _openEditorSheet(context);
  }

  void _openEditorSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickNoteEditor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        return widget.child;
      },
    );
  }
}