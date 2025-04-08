import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSharedGoalSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.teal, size: 64),
              const SizedBox(height: 12),
              Text(
                "Цель создана!",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Пусть Аллах поможет вам достичь цели 🕋",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    },
  );
}