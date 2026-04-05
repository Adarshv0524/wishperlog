// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/main.dart';

void main() {
  testWidgets('App boots with router shell', (WidgetTester tester) async {
    await init();

    await tester.pumpWidget(
      ChangeNotifierProvider<OverlayNotifier>.value(
        value: sl<OverlayNotifier>(),
        child: BlocProvider<ThemeCubit>.value(
          value: sl<ThemeCubit>(),
          child: const MyApp(),
        ),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
