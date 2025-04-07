import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/daily_ayahs.dart';
import 'shimmer_widgets.dart';

class AyahSection extends StatelessWidget {
  final bool isLoading;

  const AyahSection({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final ayah = dailyAyahs[DateTime.now().day % dailyAyahs.length];

    return isLoading
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ShimmerBox(width: double.infinity, height: 18),
        SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 14),
        SizedBox(height: 4),
        ShimmerBox(width: 100, height: 12),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ayah["arabic"] ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Amiri'),
        ),
        const SizedBox(height: 8),
        Text(
          '"${ayah["ru"]}"',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Text(
          ayah["source"] ?? '',
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}