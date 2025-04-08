import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mekka_savings_app/screens/profile/presentation/profile_provider.dart';
import 'package:mekka_savings_app/screens/profile/settings_screen.dart';
import 'package:mekka_savings_app/screens/profile/widgets/profile_header.dart';
import 'package:mekka_savings_app/screens/profile/widgets/profile_menu_buttons.dart';
import 'package:mekka_savings_app/screens/profile/widgets/profile_shimmer.dart';
import 'package:mekka_savings_app/screens/profile/widgets/profile_stats_card.dart';
import 'package:provider/provider.dart';

import '../../data/daily_ayahs.dart';
import '../../widgets/close_screen_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ayah = dailyAyahs[DateTime.now().day % dailyAyahs.length];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<ProfileProvider>().loadProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const ShimmerContent()
          : Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
                  ProfileHeader(
                    ayah: ayah,
                    nickname: provider.nickname!,
                    email: FirebaseAuth.instance.currentUser?.email ?? '',
                    bio: provider.bio!,
                  ),
                  const SizedBox(height: 20),
                  ProfileStatsCard(
                    totalSaved: provider.totalSaved,
                    transactionsCount: provider.transactionsCount,
                  ),
                  const SizedBox(height: 20),
                  const ProfileMenuButtons(),
                ],
              ),
            ),
          ),
          const CloseScreenButton(),
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