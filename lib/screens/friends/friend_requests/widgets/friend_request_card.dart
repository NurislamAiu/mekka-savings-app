import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendRequestCard extends StatelessWidget {
  final String uid;
  final String nickname;
  final String email;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const FriendRequestCard({
    super.key,
    required this.uid,
    required this.nickname,
    required this.email,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.shade100,
            child: const Icon(Icons.person, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@$nickname",
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(email, style: GoogleFonts.nunito(color: Colors.grey[700])),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 32),
            onPressed: onDecline,
          ),
        ],
      ),
    );
  }
}