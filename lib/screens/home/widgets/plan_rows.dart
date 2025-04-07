import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanRow extends StatelessWidget {
  final String label;
  final String value;

  const PlanRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[800])),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}