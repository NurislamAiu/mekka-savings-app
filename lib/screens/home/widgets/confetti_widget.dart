import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class GoalConfettiWidget extends StatelessWidget {
  final ConfettiController controller;

  const GoalConfettiWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      numberOfParticles: 30,
      gravity: 0.2,
    );
  }
}