import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekka_savings_app/screens/create_shared_goal_screen.dart';
import 'package:mekka_savings_app/screens/shared_goal_screen.dart';
import 'package:shimmer/shimmer.dart';

class MySharedGoalsScreen extends StatefulWidget {
  const MySharedGoalsScreen({super.key});

  @override
  State<MySharedGoalsScreen> createState() => _MySharedGoalsScreenState();
}

class _MySharedGoalsScreenState extends State<MySharedGoalsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> goals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSharedGoals();
  }

  Future<void> _loadSharedGoals() async {
    setState(() => isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('sharedGoals')
        .where('memberUIDs', arrayContains: user!.uid)
        .get();

    setState(() {
      goals = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      isLoading = false;
    });
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.teal, size: 64),
                SizedBox(height: 12),
                Text(
                  "Цель создана!",
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Пусть Аллах поможет вам достичь цели 🕋",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, width: 150, color: Colors.white),
              SizedBox(height: 10),
              Container(height: 14, width: 200, color: Colors.white),
              SizedBox(height: 14),
              Container(height: 8, width: double.infinity, color: Colors.white),
              SizedBox(height: 10),
              Container(height: 14, width: 100, color: Colors.white),
            ],
          ),
        ),
      ),
    );
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
            child: RefreshIndicator(
              onRefresh: _loadSharedGoals,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: Row(
                      children: [
                        SvgPicture.asset('assets/kaaba.svg', height: 32),
                        SizedBox(width: 8),
                        Text(
                          "Общие цели",
                          style: GoogleFonts.cairo(
                              color: Colors.brown[800],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: isLoading
                        ? _buildShimmer()
                        : goals.isEmpty
                        ? Center(
                      child: Text(
                        "У тебя пока нет общих целей 😌",
                        style: GoogleFonts.nunito(
                            fontSize: 16, color: Colors.grey[700]),
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final progress =
                            (goal['savedAmount'] ?? 0) / (goal['targetAmount'] ?? 1);

                        final List members = goal['members'] ?? [];
                        final waiting = members.any((m) => m['confirmed'] == false);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SharedGoalScreen(goalId: goal['id']),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title'] ?? "Без названия",
                                    style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown[800]),
                                  ),
                                  SizedBox(height: 6),
                                  if (waiting)
                                    Row(
                                      children: [
                                        Icon(Icons.hourglass_empty,
                                            color: Colors.orange, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          "Ожидание участников...",
                                          style: GoogleFonts.nunito(
                                              color: Colors.orange, fontSize: 13),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      goal['description'] ?? "Общая цель друзей 🫂",
                                      style: GoogleFonts.nunito(
                                          color: Colors.grey[700], fontSize: 14),
                                    ),
                                  SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey[200],
                                      color: Colors.teal,
                                      minHeight: 8,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${goal['savedAmount']?.toStringAsFixed(0)} / ${goal['targetAmount']?.toStringAsFixed(0)} тг",
                                        style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.group,
                                              size: 16, color: Colors.teal[700]),
                                          SizedBox(width: 4),
                                          Text("${members.length}",
                                              style: GoogleFonts.nunito(fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateSharedGoalScreen()),
          );

          if (result == true) {
            _loadSharedGoals(); 
            _showSuccessAnimation(); 
          }
        },
        child: Icon(Icons.notes, size: 24, color: Colors.teal),
      ),
    );
  }
}