import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'shared_goal_screen.dart';

class MySharedGoalsScreen extends StatefulWidget {
  const MySharedGoalsScreen({super.key});

  @override
  State<MySharedGoalsScreen> createState() => _MySharedGoalsScreenState();
}

class _MySharedGoalsScreenState extends State<MySharedGoalsScreen> with SingleTickerProviderStateMixin {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> goals = [];
  bool isLoading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _loadSharedGoals();
  }

  Future<void> _loadSharedGoals() async {
    setState(() => isLoading = true);
    final uid = currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance.collection('sharedGoals').get();

    final filtered = snapshot.docs.where((doc) {
      final raw = doc['members'];
      if (raw is! List) return false;
      final members = List<Map<String, dynamic>>.from(raw);
      return members.any((m) => m['uid'] == uid);
    }).map((doc) => {'id': doc.id, ...doc.data()}).toList();

    setState(() {
      goals = filtered;
      isLoading = false;
    });

    _animController.forward(from: 0); // запускаем fade анимацию
  }

  void _removeGoalFromList(String goalId) {
    setState(() {
      goals.removeWhere((g) => g['id'] == goalId);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: Text("🌍 Общие цели", style: GoogleFonts.cairo()),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSharedGoals,
        child: isLoading
            ? _buildShimmerLoading()
            : goals.isEmpty
            ? ListView(
          children: [
            SizedBox(height: 100),
            Center(
              child: SvgPicture.asset('assets/kaaba.svg', height: 100),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Общих целей пока нет",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final double saved = goal['savedAmount']?.toDouble() ?? 0;
            final double target = goal['targetAmount']?.toDouble() ?? 1;
            final progress = saved / target;

            final members = List<Map<String, dynamic>>.from(goal['members'] ?? []);
            final description = goal['description'] ?? '';
            final memberNames = members.map((m) => "@${m['nickname']}").join(', ');

            return AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: Card(
                key: ValueKey(goal['id']),
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(goal['title'], style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                          child: Text(
                            description,
                            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[700]),
                          ),
                        ),
                      if (memberNames.isNotEmpty)
                        Text(
                          "👥 $memberNames",
                          style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
                        ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.teal,
                      ),
                      SizedBox(height: 4),
                      Text("${saved.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} тг"),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    // Передаём коллбэк для удаления из списка
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SharedGoalScreen(goalId: goal['id']),
                      ),
                    );
                    _loadSharedGoals(); // обновим список после возврата
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            height: 100,
          ),
        );
      },
    );
  }
}