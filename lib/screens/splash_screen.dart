import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'auth/auth_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 2500));
      setState(() => _visible = false);

      await Future.delayed(const Duration(milliseconds: 600));
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        user != null ? '/home' : '/auth',
      );
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: _visible ? 1.0 : 0.0,
          child: RotationTransition(
            turns: _rotationController,
            child: SvgPicture.asset(
              'assets/kaaba.svg',
              height: 100,
            ),
          ),
        ),
      ),
    );
  }
}