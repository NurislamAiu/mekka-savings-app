import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../presentation/friends_provider.dart';

class FriendResultCard extends StatelessWidget {
  const FriendResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FriendsProvider>(context);
    final user = provider.foundUser;
    final status = provider.status;

    if (user == null) return SizedBox.shrink();

    Widget statusWidget() {
      switch (status) {
        case 'self':
          return Text("Это ты 😊", style: GoogleFonts.nunito(color: Colors.grey));
        case 'not_found':
          return Text("Пользователь не найден ❌", style: GoogleFonts.nunito(color: Colors.red));
        case 'already_friends':
          return Text("Уже в друзьях 🫂", style: GoogleFonts.nunito(color: Colors.green));
        case 'request_sent':
          return Text("Запрос уже отправлен 🕊", style: GoogleFonts.nunito(color: Colors.orange));
        case 'can_add':
          return ElevatedButton.icon(
            onPressed: () => provider.sendFriendRequest(context),
            icon: Icon(Icons.person_add, color: Colors.white),
            label: Text("Добавить в друзья", style: GoogleFonts.nunito(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        default:
          return SizedBox.shrink();
      }
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("@${user.nickname}", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(user.email, style: GoogleFonts.nunito(color: Colors.grey[700])),
          SizedBox(height: 14),
          statusWidget(),
        ],
      ),
    );
  }
}