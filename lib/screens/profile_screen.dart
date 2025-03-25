import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'create_shared_goal_screen.dart';
import 'friends_screen.dart';
import 'my_shared_goals_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? nickname;
  String? bio;
  int transactionsCount = 0;
  double totalSaved = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final goalDoc = await FirebaseFirestore.instance.collection('goals').doc('mekkaTrip').get();
    final txSnapshot = await FirebaseFirestore.instance
        .collection('goals')
        .doc('mekkaTrip')
        .collection('transactions')
        .where('userId', isEqualTo: user!.uid)
        .get();

    final userData = userDoc.data();

    setState(() {
      nickname = userData?['nickname'];
      bio = userData != null && userData.containsKey('bio')
          ? userData['bio']
          : "Коплю на Умру с друзьями 🕋";
      totalSaved = (goalDoc.data()?['savedAmount'] ?? 0).toDouble();
      transactionsCount = txSnapshot.docs.length;
      isLoading = false;
    });
  }

  void _editField(String label, String key, String? initialValue) {
    final controller = TextEditingController(text: initialValue ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Изменить $label"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Отмена")),
          if (key == 'bio')
            TextButton(
              onPressed: () async {
                final defaultBio = "Коплю на Умру с друзьями 🕋";
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .set({'bio': defaultBio}, SetOptions(merge: true));
                setState(() => bio = defaultBio);
                Navigator.pop(context);
              },
              child: Text("Сбросить"),
            ),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .set({key: value}, SetOptions(merge: true));
                setState(() {
                  if (key == 'nickname') nickname = value;
                  if (key == 'bio') bio = value;
                });
                Navigator.pop(context);
              }
            },
            child: Text("Сохранить"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDF9),
      body: isLoading
          ? _buildShimmerProfile()
          : SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // 🌙 Хадис
              Column(
                children: [
                  Text(
                    "إِنَّ أَحَبَّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontFamily: 'Amiri', height: 1.8),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "«Поистине, самые любимые дела перед Аллахом — те, что постоянны, даже если малы»",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24),
                ],
              ),

              // 👳 Аватар
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.teal.shade50,
                child: SvgPicture.asset('assets/kaaba.svg', height: 40),
              ),
              SizedBox(height: 12),

              // 🏷️ Ник и email
              Text(
                user?.displayName ?? "Без имени",
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(user?.email ?? '', style: GoogleFonts.nunito(color: Colors.grey[700])),
              SizedBox(height: 6),

              // 🏷️ Никнейм
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (nickname != null)
                    Text(
                      "@$nickname",
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.teal[700]),
                    ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 16),
                    onPressed: () => _editField("никнейм", "nickname", nickname),
                  ),
                ],
              ),

              // ✍️ Био
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      bio ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_note, size: 18),
                    onPressed: () => _editField("био", "bio", bio),
                  ),
                ],
              ),

              Divider(height: 40),

              // 📊 Статистика
              _statCard("💰 Всего накоплено", "${totalSaved.toStringAsFixed(0)} тг"),
              _statCard("🧾 Кол-во взносов", "$transactionsCount"),

              SizedBox(height: 30),

              // 🫂 Кнопки
              _menuButton(Icons.group_outlined, "Мои друзья", FriendsScreen()),
              _menuButton(Icons.flag_outlined, "Общие цели", MySharedGoalsScreen()),
              _menuButton(Icons.add_circle_outline, "Создать цель", CreateSharedGoalScreen()),

              SizedBox(height: 30),

              // 🚪 Выход
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text("Выйти с миром 🌙", style: GoogleFonts.nunito(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async => await FirebaseAuth.instance.signOut(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.teal.shade50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.nunito(fontSize: 15, color: Colors.grey[800])),
          Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _menuButton(IconData icon, String title, Widget screen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(title, style: GoogleFonts.nunito(fontSize: 15)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.teal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }

  Widget _buildShimmerProfile() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 60),
          ShimmerBox(width: 80, height: 80, isCircle: true),
          SizedBox(height: 16),
          ShimmerBox(width: 160, height: 20),
          SizedBox(height: 10),
          ShimmerBox(width: 200, height: 14),
          SizedBox(height: 10),
          ShimmerBox(width: 140, height: 14),
          SizedBox(height: 20),
          ShimmerBox(width: double.infinity, height: 80),
          SizedBox(height: 20),
          ShimmerBox(width: double.infinity, height: 48),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 48),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 48),
          Spacer(),
          ShimmerBox(width: double.infinity, height: 50),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircle;

  const ShimmerBox({super.key, required this.width, required this.height, this.isCircle = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(12),
        ),
      ),
    );
  }
}