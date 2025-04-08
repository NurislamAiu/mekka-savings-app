import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../friends/my_friends_screen.dart';
import '../../goals/my_shared_goals/my_shared_goals_screen.dart';

class ProfileMenuButtons extends StatelessWidget {
  const ProfileMenuButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _menuButton(
          context,
          icon: Icons.group_outlined,
          title: "Друзья",
          screen: const MyFriendsScreen(),
        ),
        _menuButton(
          context,
          icon: Icons.flag_outlined,
          title: "Цели",
          screen: const MySharedGoalsScreen(),
        ),
      ],
    );
  }

  Widget _menuButton(BuildContext context, {
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.teal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          child: Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}