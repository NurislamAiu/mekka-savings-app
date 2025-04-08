import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedGoalProgress extends StatelessWidget {
  final double progress;
  final int savedAmount;
  final int targetAmount;

  const SharedGoalProgress({
    super.key,
    required this.progress,
    required this.savedAmount,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    final Color barColor = Colors.teal;
    final Color backgroundBarColor = Colors.grey[200]!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Прогресс",
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: backgroundBarColor,
                color: barColor,
                minHeight: 10,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "$savedAmount / $targetAmount тг",
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}