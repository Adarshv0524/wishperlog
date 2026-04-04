import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/features/capture/overlay/overlay_window_controller.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class OverlayCustomizationScreen extends StatefulWidget {
  const OverlayCustomizationScreen({super.key});

  @override
  State<OverlayCustomizationScreen> createState() =>
      _OverlayCustomizationScreenState();
}

class _OverlayCustomizationScreenState extends State<OverlayCustomizationScreen> {
  final AppPreferencesRepository _prefs = sl<AppPreferencesRepository>();
  final UserRepository _users = sl<UserRepository>();

  bool _loading = true;
  bool _visible = true;
  double _opacity = 0.84;
  bool _snapEnabled = true;
  double _bubbleSize = 76;
  double _bannerHeight = 0.36;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final visible = await _prefs.isOverlayVisible();
    final opacity = await _prefs.getOverlayOpacity();
    final snapEnabled = await _prefs.isOverlaySnapEnabled();
    final bubbleSize = await _prefs.getOverlayBubbleSize();
    final bannerHeight = await _prefs.getOverlayBannerHeightFactor();
    if (!mounted) {
      return;
    }
    setState(() {
      _visible = visible;
      _opacity = opacity;
      _snapEnabled = snapEnabled;
      _bubbleSize = bubbleSize;
      _bannerHeight = bannerHeight;
      _loading = false;
    });
    await OverlayWindowController.applyCustomization();
  }

  Future<void> _setVisible(bool value) async {
    await _prefs.setOverlayVisible(value);
    await _users.updateOverlayVisibility(value);
    if (value) {
      final granted = await OverlayWindowController.ensurePermission();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Overlay permission denied.')),
        );
        await _prefs.setOverlayVisible(false);
        value = false;
      } else {
        await OverlayWindowController.showBubble();
      }
    } else {
      await FlutterOverlayWindow.closeOverlay();
    }
    if (!mounted) return;
    setState(() {
      _visible = value;
    });
  }

  Future<void> _commit({
    double? opacity,
    bool? snapEnabled,
    double? bubbleSize,
    double? bannerHeight,
  }) async {
    if (opacity != null) {
      _opacity = opacity.clamp(0.2, 1.0);
      await _prefs.setOverlayOpacity(_opacity);
    }
    if (snapEnabled != null) {
      _snapEnabled = snapEnabled;
      await _prefs.setOverlaySnapEnabled(_snapEnabled);
    }
    if (bubbleSize != null) {
      _bubbleSize = bubbleSize.clamp(64.0, 120.0);
      await _prefs.setOverlayBubbleSize(_bubbleSize);
    }
    if (bannerHeight != null) {
      _bannerHeight = bannerHeight.clamp(0.28, 0.50);
      await _prefs.setOverlayBannerHeightFactor(_bannerHeight);
    }

    if (!mounted) {
      return;
    }
    setState(() {});
    await OverlayWindowController.applyCustomization(
      rebuildBubble: snapEnabled != null || bubbleSize != null,
    );
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
        title: const Text('Overlay Settings & Behavior'),
      ),
      body: GlassPageBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                children: [
                  _sectionHeader('Visibility'),
                  GlassContainer(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    borderRadius: BorderRadius.circular(18),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Floating overlay visible'),
                      subtitle: const Text('Show or hide the overlay button immediately.'),
                      value: _visible,
                      onChanged: _setVisible,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionHeader('Appearance'),
                  GlassContainer(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bubble transparency',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _opacity,
                          min: 0.2,
                          max: 1.0,
                          divisions: 8,
                          label: '${(_opacity * 100).round()}%',
                          onChanged: (value) => _commit(opacity: value),
                        ),
                        Text(
                          'Current opacity: ${(_opacity * 100).round()}%',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bubble size',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Slider(
                          value: _bubbleSize,
                          min: 64,
                          max: 120,
                          divisions: 14,
                          label: '${_bubbleSize.round()} px',
                          onChanged: (value) => _commit(bubbleSize: value),
                        ),
                        Text(
                          'Current size: ${_bubbleSize.round()} px',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionHeader('Behavior'),
                  GlassContainer(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Smoothness / snapping'),
                          subtitle: const Text(
                            'Stick the bubble to the nearest edge when dragging.',
                          ),
                          value: _snapEnabled,
                          onChanged: (value) => _commit(snapEnabled: value),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Banner height',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Slider(
                          value: _bannerHeight,
                          min: 0.28,
                          max: 0.50,
                          divisions: 11,
                          label: '${(_bannerHeight * 100).round()}% of screen',
                          onChanged: (value) => _commit(bannerHeight: value),
                        ),
                        Text(
                          'Current banner height: ${(_bannerHeight * 100).round()}%',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        const SizedBox(height: 8),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Hold: Records voice instantly. Double-Tap: Opens text banner.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionHeader('Live preview'),
                  GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(18),
                    child: Row(
                      children: [
                        Icon(Icons.blur_on_rounded, color: Colors.white.withValues(alpha: 0.9)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Changes apply immediately to the active overlay bubble or banner.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}