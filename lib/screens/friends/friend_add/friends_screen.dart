import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekka_savings_app/screens/friends/friend_add/presentation/friends_provider.dart';
import 'package:mekka_savings_app/screens/friends/friend_add/widgets/friend_result_card.dart';
import 'package:mekka_savings_app/screens/friends/friend_add/widgets/search_field.dart';
import 'package:provider/provider.dart';

import '../../../widgets/close_screen_button.dart';
import '../friend_requests/friend_requests_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SvgPicture.asset('assets/kaaba.svg', height: 50),
                    SizedBox(height: 10),
                    Text("Пригласи друзей к Умре 🕋", style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[800])),
                    SizedBox(height: 10),
                    Text("«Кто указал на благое — тот получит награду подобную награде совершающего это благое» (Хадис)", textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[700])),
                    SizedBox(height: 20),
                    const SearchField(),
                    SizedBox(height: 24),
                    Consumer<FriendsProvider>(
                      builder: (_, provider, __) {
                        if (provider.isSearching) return CircularProgressIndicator();
                        return provider.foundUser != null ? const FriendResultCard() : SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            CloseScreenButton(),
          ],
        ),
        floatingActionButton: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            bool hasRequests = false;
            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final requests = data?['friendRequests'] as List<dynamic>? ?? [];
              hasRequests = requests.isNotEmpty;
            }

            return Stack(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FriendRequestsScreen()));
                  },
                  child: Icon(Icons.notifications_active_outlined, size: 24, color: Colors.teal),
                ),
                if (hasRequests)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
              ],
            );
          },
        ),
      );
  }
}