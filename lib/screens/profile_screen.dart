import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mekka_savings_app/screens/settings_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../data/daily_ayahs.dart';
import 'friends_screen.dart';
import 'my_friends_screen.dart';
import 'my_shared_goals_screen.dart';
import 'create_shared_goal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? nickname, bio;
  int transactionsCount = 0;
  double totalSaved = 0;
  bool isLoading = true;
  final ayah = dailyAyahs[DateTime.now().day % dailyAyahs.length];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
    final goalDoc =
        await FirebaseFirestore.instance
            .collection('goals')
            .doc('mekkaTrip')
            .get();
    final txSnapshot =
        await goalDoc.reference
            .collection('transactions')
            .where('userId', isEqualTo: user!.uid)
            .get();

    setState(() {
      nickname = userDoc.data()?['nickname'] ?? '';
      bio = userDoc.data()?['bio'] ?? 'Коплю на Умру 🕋';
      totalSaved = (goalDoc.data()?['savedAmount'] ?? 0).toDouble();
      transactionsCount = txSnapshot.docs.length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? _buildShimmer()
              : Stack(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ayah["arabic"]!,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 18,
                                      height: 1.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '"${ayah["ru"]}"',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    ayah["source"]!,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: SvgPicture.asset(
                              'assets/kaaba.svg',
                              height: 48,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "@$nickname" ?? "Без имени",
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: GoogleFonts.nunito(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 6),
                          SizedBox(height: 4),
                          Text(
                            bio!,
                            style: GoogleFonts.nunito(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 20),

                          
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _statRow(
                                    "💰 Всего накоплено",
                                    "${totalSaved.toStringAsFixed(0)} тг",
                                  ),
                                  _statRow(
                                    "🧾 Кол-во взносов",
                                    "$transactionsCount",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          
                          Row(
                            children: [
                              _menuButton(
                                Icons.group_outlined,
                                "Друзья",
                                MyFriendsScreen(),
                              ),
                              _menuButton(
                                Icons.flag_outlined,
                                "Цели",
                                MySharedGoalsScreen(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 24,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SettingsScreen()),
          );
        },
        child: Icon(Icons.settings, size: 24, color: Colors.teal),
      ),
    );
  }

  Widget _statRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GoogleFonts.nunito(fontSize: 15)),
      Text(
        value,
        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );

  Widget _menuButton(IconData icon, String title, Widget screen) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.teal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
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

  Widget _buildShimmer() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: CircleAvatar(radius: 50, backgroundColor: Colors.white),
            ),
            SizedBox(height: 20),
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
