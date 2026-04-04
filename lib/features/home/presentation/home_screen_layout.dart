import 'package:flutter/widgets.dart';

import 'screens/home_screen.dart';

/// Router-facing wrapper to keep compatibility with existing route references.
class HomeScreenLayout extends StatelessWidget {
	const HomeScreenLayout({super.key});

	@override
	Widget build(BuildContext context) {
		return const HomeScreen();
	}
}
