import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mekka_savings_app/screens/friends/friend_add/friends_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/close_screen_button.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({super.key});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    setState(() => isLoading = true);

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
    final List<String> friendUIDs = List<String>.from(
      userDoc.data()?['friends'] ?? [],
    );

    List<Map<String, dynamic>> result = [];

    for (String uid in friendUIDs) {
      final friendDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (friendDoc.exists) {
        result.add({
          'uid': uid,
          'nickname': friendDoc['nickname'] ?? '',
          'email': friendDoc['email'] ?? '',
        });
      }
    }

    setState(() {
      friends = result;
      isLoading = false;
    });
  }

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/kaaba.svg', height: 32),
                      SizedBox(width: 12),
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
                      Text(
                        "المرء على دين خليله فلينظر أحدكم من يخالل",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Amiri',
                          height: 1.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "«Человек следует религии своего друга. Пусть каждый смотрит, кого выбирает себе в друзья.»",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      isLoading
                          ? _buildShimmer()
                          : RefreshIndicator(
                            onRefresh: loadFriends,
                            child:
                                friends.isEmpty
                                    ? ListView(
                                      children: [
                                        SizedBox(height: 100),
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
                                    )
                                    : ListView.builder(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      itemCount: friends.length,
                                      itemBuilder: (context, index) {
                                        final f = friends[index];
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 3,
                                          margin: EdgeInsets.only(bottom: 12),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  Colors.teal.shade100,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.teal[800],
                                              ),
                                            ),
                                            title: Text(
                                              "@${f['nickname']}",
                                              style: GoogleFonts.nunito(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(f['email']),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                ),
              ],
            ),
          ),
          CloseScreenButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FriendsScreen()),
          );
        },
        child: Icon(Icons.person_add_alt, size: 24, color: Colors.teal),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 6,
      itemBuilder:
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                ),
                title: Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.white,
                ),
                subtitle: Container(
                  height: 12,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 8),
                  color: Colors.white,
                ),
              ),
            ),
          ),
    );
  }
}
