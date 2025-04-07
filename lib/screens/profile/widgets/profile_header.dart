import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, String> ayah;
  final String nickname;
  final String email;
  final String bio;

  const ProfileHeader({
    super.key,
    required this.ayah,
    required this.nickname,
    required this.email,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Аят
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ayah["arabic"] ?? '',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"${ayah["ru"]}"',
                style: GoogleFonts.nunito(color: Colors.grey[700]),
              ),
              Text(
                ayah["source"] ?? '',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Аватар, ник, почта и био
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: SvgPicture.asset(
            'assets/kaaba.svg',
            height: 48,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "@$nickname",
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: GoogleFonts.nunito(color: Colors.grey[600]),
        ),
        const SizedBox(height: 6),
        Text(
          bio,
          style: GoogleFonts.nunito(color: Colors.grey[700]),
        ),
      ],
    );
  }
}