import 'package:flutter/material.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/features/overlay_v1/presentation/widgets/overlay_bubble_widget.dart';

@pragma('vm:entry-point')
Future<void> overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[OverlayMain] Overlay isolate starting');
  
  try {
    final isar = await IsarService.instance.init();
    debugPrint('[OverlayMain] Isar initialized: $isar');
  } catch (error, stackTrace) {
    debugPrint('[OverlayMain] Isar init failed (overlay still usable): $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  
  debugPrint('[OverlayMain] Booting OverlayV1App with OverlayBubbleWidget');
  runApp(const OverlayV1App());
}

class OverlayV1App extends StatelessWidget {
  const OverlayV1App({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[OverlayV1App] Building MaterialApp with Scaffold and OverlayBubbleWidget');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_DebugNavigatorObserver()],
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Builder(
            builder: (context) {
              debugPrint('[OverlayV1App] OverlayBubbleWidget rendering');
              return const OverlayBubbleWidget();
            },
          ),
        ),
      ),
    );
  }
}

class _DebugNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('[OverlayNav] PUSH: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('[OverlayNav] POP: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    debugPrint('[OverlayNav] REPLACE: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }
}

