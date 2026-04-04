import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/overlay_v1/domain/overlay_bubble_config.dart';
import 'package:wishperlog/features/overlay_v1/overlay_coordinator.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class OverlayCustomizationScreen extends StatefulWidget {
  const OverlayCustomizationScreen({super.key});

  @override
  State<OverlayCustomizationScreen> createState() =>
      _OverlayCustomizationScreenState();
}

class _OverlayCustomizationScreenState extends State<OverlayCustomizationScreen> {
  final OverlayCoordinator _overlayCoordinator = sl<OverlayCoordinator>();

  bool _loading = true;
  OverlayBubbleConfig _config = OverlayBubbleConfig.defaults;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final config = await _overlayCoordinator.getBubbleConfig();
    if (!mounted) {
      return;
    }
    setState(() {
      _config = config;
      _loading = false;
    });
  }

  Future<void> _setOpacity(double value) async {
    await _overlayCoordinator.updateBubbleConfig(opacity: value);
    if (!mounted) {
      return;
    }
    setState(() {
      _config = _config.copyWith(opacity: value);
    });
  }

  Future<void> _setSize(double value) async {
    await _overlayCoordinator.updateBubbleConfig(size: value);
    if (!mounted) {
      return;
    }
    setState(() {
      _config = _config.copyWith(size: value);
    });
  }

  Future<void> _setSnapEnabled(bool value) async {
    await HapticFeedback.selectionClick();
    await _overlayCoordinator.updateBubbleConfig(snapEnabled: value);
    if (!mounted) {
      return;
    }
    setState(() {
      _config = _config.copyWith(snapEnabled: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Overlay Customization'),
      ),
      body: GlassPageBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                children: [
                  GlassContainer(
                    borderRadius: BorderRadius.circular(18),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opacity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Slider(
                          value: _config.opacity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          label: _config.opacity.toStringAsFixed(2),
                          onChanged: _setOpacity,
                        ),
                        Text(
                          'Current: ${_config.opacity.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Bubble Size',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Slider(
                          value: _config.size,
                          min: 40,
                          max: 80,
                          divisions: 20,
                          label: '${_config.size.toStringAsFixed(0)} dp',
                          onChanged: _setSize,
                        ),
                        Text(
                          'Current: ${_config.size.toStringAsFixed(0)}dp',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile.adaptive(
                          value: _config.snapEnabled,
                          onChanged: _setSnapEnabled,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Snap To Edge'),
                          subtitle: const Text(
                            'When off, the bubble stays where you release it.',
                          ),
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
