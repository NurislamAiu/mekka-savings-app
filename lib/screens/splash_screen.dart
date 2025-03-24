import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({required this.nextScreen});

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
      duration: Duration(seconds: 2),
    )..repeat();

    // Через 2.5 секунды — переход
    Future.delayed(Duration(milliseconds: 2500), () {
      setState(() => _visible = false);
      Future.delayed(Duration(milliseconds: 600), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen),
        );
      });
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
      backgroundColor: Color(0xFFFDF6EE),
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 600),
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