import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showGoalReachedDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'GoalReached',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, _, __) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/kaaba.svg', height: 60),
                const SizedBox(height: 20),
                const Text(
                  "🎉 Поздравляем!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Ты достиг своей цели! 🕋\nАллах примет твои старания и намерения.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text("Альхамдулиллях", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}