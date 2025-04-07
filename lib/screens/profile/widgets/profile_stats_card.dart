import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStatsCard extends StatelessWidget {
  final double totalSaved;
  final int transactionsCount;

  const ProfileStatsCard({
    super.key,
    required this.totalSaved,
    required this.transactionsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _statRow("💰 Всего накоплено", "${totalSaved.toStringAsFixed(0)} тг"),
            const SizedBox(height: 10),
            _statRow("🧾 Кол-во взносов", "$transactionsCount"),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.nunito(fontSize: 15)),
        Text(
          value,
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}