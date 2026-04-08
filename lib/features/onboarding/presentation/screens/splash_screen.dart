import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(28),
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 48),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome to WhisperLog',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A fast note workspace with AI-assisted capture and calm motion.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/signin'),
                    child: const Text('Enter the workspace'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
