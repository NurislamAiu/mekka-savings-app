import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalStatusText extends StatelessWidget {
  final bool isLoading;
  final String status;

  const GoalStatusText({super.key, required this.isLoading, required this.status});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: 20);
    }

    Color color;
    if (status.contains("✅")) {
      color = Colors.green;
    } else if (status.contains("⚠️")) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Text(
      status,
      style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: color),
    );
  }
}