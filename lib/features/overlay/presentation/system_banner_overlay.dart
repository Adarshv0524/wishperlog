import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';
import 'package:wishperlog/shared/widgets/molecules/dynamic_notch_pill.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class SystemBannerOverlay extends StatefulWidget {
  final String mode;
  const SystemBannerOverlay({super.key, required this.mode});

  @override
  State<SystemBannerOverlay> createState() => _SystemBannerOverlayState();
}

class _SystemBannerOverlayState extends State<SystemBannerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep background entirely transparent so the OS is visible
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: widget.mode == 'island' ? _buildDynamicIsland() : _buildTruecallerInput(),
          ),
        ),
      ),
    );
  }

  Widget _buildTruecallerInput() {
    return Dismissible(
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
    );
  }

  Widget _buildDynamicIsland() {
    return BlocConsumer<CaptureUiController, CaptureUiState>(
      bloc: sl<CaptureUiController>(),
      listener: (context, state) {
        if (state is CaptureUiIdle) {
          if (context.mounted && GoRouter.of(context).canPop()) {
            context.pop();
          }
        }
      },
      builder: (context, state) {
        if (state is CaptureUiIdle) {
          return const SizedBox.shrink();
        }

        return const UnifiedDynamicIsland();
      },
    );
  }
}
