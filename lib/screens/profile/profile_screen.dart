import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/daily_ayahs.dart';
import '../../widgets/close_screen_button.dart';
import '../profile/widgets/profile_header.dart';
import '../profile/widgets/profile_stats_card.dart';
import '../profile/widgets/profile_menu_buttons.dart';
import '../profile/widgets/profile_shimmer.dart';
import '../profile/settings_screen.dart';

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
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final goalDoc =
    await FirebaseFirestore.instance.collection('goals').doc('mekkaTrip').get();
    final txSnapshot = await goalDoc.reference
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
      body: isLoading
          ? const ShimmerContent()
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ProfileHeader(ayah: ayah, nickname: nickname!, email: user?.email ?? '', bio: bio!),
                  const SizedBox(height: 20),
                  ProfileStatsCard(totalSaved: totalSaved, transactionsCount: transactionsCount),
                  const SizedBox(height: 20),
                  const ProfileMenuButtons(),
                ],
              ),
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
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
        child: const Icon(Icons.settings, size: 24, color: Colors.teal),
      ),
    );
  }
}