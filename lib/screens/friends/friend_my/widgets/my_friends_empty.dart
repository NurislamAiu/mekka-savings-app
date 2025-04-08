import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyFriendsEmpty extends StatelessWidget {
  const MyFriendsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Text(
            "У тебя пока нет друзей 😌",
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}