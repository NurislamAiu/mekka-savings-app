import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MyFriendsHeader extends StatelessWidget {
  const MyFriendsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              SvgPicture.asset('assets/kaaba.svg', height: 32),
              const SizedBox(width: 12),
              Text(
                "Мои друзья",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Text(
                "المرء على دين خليله فلينظر أحدكم من يخالل",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontFamily: 'Amiri', height: 1.8),
              ),
              const SizedBox(height: 4),
              Text(
                "«Человек следует религии своего друга. Пусть каждый смотрит, кого выбирает себе в друзья.»",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}