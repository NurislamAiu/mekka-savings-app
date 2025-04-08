import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekka_savings_app/screens/goals/shared_goal/shared_goal_screen.dart';

class SharedGoalCard extends StatelessWidget {
  final Map<String, dynamic> goal;

  const SharedGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (goal['savedAmount'] ?? 0) / (goal['targetAmount'] ?? 1);
    final List members = goal['members'] ?? [];
    final waiting = members.any((m) => m['confirmed'] == false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SharedGoalScreen(goalId: goal['id']),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal['title'] ?? "Без названия",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 6),
              if (waiting)
                Row(
                  children: [
                    const Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Ожидание участников...",
                      style: GoogleFonts.nunito(color: Colors.orange, fontSize: 13),
                    ),
                  ],
                )
              else
                Text(
                  goal['description'] ?? "Общая цель друзей 🫂",
                  style: GoogleFonts.nunito(color: Colors.grey[700], fontSize: 14),
                ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  color: Colors.teal,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${goal['savedAmount']?.toStringAsFixed(0)} / ${goal['targetAmount']?.toStringAsFixed(0)} тг",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: Colors.teal[700]),
                      const SizedBox(width: 4),
                      Text("${members.length}", style: GoogleFonts.nunito(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}