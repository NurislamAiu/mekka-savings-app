import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'auth/auth_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
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

    
    Future.delayed(Duration(milliseconds: 2500), () async {
      setState(() => _visible = false);

      await Future.delayed(Duration(milliseconds: 600)); 
      final user = FirebaseAuth.instance.currentUser;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user != null
              ? HomeScreen(userId: user.uid)
              : AuthScreen(),
        ),
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