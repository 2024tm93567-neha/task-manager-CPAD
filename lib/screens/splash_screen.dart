import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final isLoggedIn = await AuthService().isLoggedIn();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(isLoggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 52),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 800.ms),
            const SizedBox(height: 20),
            Text(
              'Task Manager',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'Powered by Back4App',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
