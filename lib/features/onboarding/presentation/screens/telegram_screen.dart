import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TelegramScreen extends StatelessWidget {
  const TelegramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Connect Telegram'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Mock connect
                context.go('/home');
              },
              child: const Text('Connect'),
            ),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
