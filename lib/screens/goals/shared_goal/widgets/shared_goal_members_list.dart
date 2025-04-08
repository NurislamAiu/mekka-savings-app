import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedGoalMembersList extends StatelessWidget {
  final List<Map<String, dynamic>> members;

  const SharedGoalMembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "👥 Участники",
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...members.map((m) => Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(Icons.person, color: Colors.teal),
            ),
            title: Text(
              "@${m['nickname']}",
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(m['email']),
            trailing: (m['confirmed'] == true)
                ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                : Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
          ),
        )),
      ],
    );
  }
}