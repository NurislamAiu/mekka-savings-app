import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/shared_goal_provider.dart';

class SharedGoalScreen extends StatelessWidget {
  final String goalId;
  const SharedGoalScreen({required this.goalId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SharedGoalProvider()..loadSharedGoal(goalId),
      child: Scaffold(
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
              child: Consumer<SharedGoalProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading)
                    return _buildShimmer(); 

                  if (provider.goalData == null)
                    return Center(child: Text("❗ Цель не найдена"));

                  final goal = provider.goalData!;
                  final progress =
                      (goal['savedAmount'] ?? 0) / (goal['targetAmount'] ?? 1);
                  final members = provider.members;
                  final currentUserId = provider.currentUser!.uid;

                  return ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/kaaba.svg', height: 40),
                          SizedBox(width: 10),
                          Text(goal['title'] ?? 'Общая цель',
                              style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[800])),
                        ],
                      ),
                      SizedBox(height: 20),

                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Прогресс",
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.teal,
                                  minHeight: 10,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${goal['savedAmount']} / ${goal['targetAmount']} тг",
                                style: GoogleFonts.nunito(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      if (!_isUserConfirmed(members, currentUserId))
                        ElevatedButton.icon(
                          onPressed: () => _confirmParticipation(provider, context),
                          icon: Icon(Icons.check_circle, color: Colors.white),
                          label: Text("Подтвердить участие"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),

                      SizedBox(height: 24),

                      Text("👥 Участники",
                          style: GoogleFonts.nunito(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ...members.map((m) => Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Icon(Icons.person, color: Colors.teal),
                          ),
                          title: Text("@${m['nickname']}",
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(m['email']),
                          trailing: (m['confirmed'] == true)
                              ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                              : Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                        ),
                      )),

                      SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: () => _confirmExit(context, provider, goalId),
                        icon: Icon(Icons.exit_to_app),
                        label: Text("Выйти из цели"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),

                      SizedBox(height: 24),

                      Text(
                        '“Аллах вместе с теми, кто проявляет терпение.” (Сура Аль-Бакара 153)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isUserConfirmed(List members, String uid) {
    final user = members.firstWhere(
          (m) => m['uid'] == uid,
      orElse: () => <String, dynamic>{},
    );
    return user['confirmed'] == true;
  }

  void _confirmParticipation(SharedGoalProvider provider, BuildContext context) async {
    final docRef = FirebaseFirestore.instance.collection('sharedGoals').doc(goalId);
    final docSnap = await docRef.get();
    final members = List.from(docSnap['members']);

    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final currentMember = members.firstWhere(
          (m) => m['uid'] == currentUserUid,
      orElse: () => <String, dynamic>{},
    );

    if (currentMember.isNotEmpty && currentMember['confirmed'] == false) {
      currentMember['confirmed'] = true;
      bool allConfirmed = members.every((m) => m['confirmed'] == true);
      await docRef.update({'members': members, 'confirmed': allConfirmed});
      provider.loadSharedGoal(goalId);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Участие подтверждено 🌙")));
    }
  }

  void _confirmExit(BuildContext context, SharedGoalProvider provider, String goalId) {
    
  }

  
  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}