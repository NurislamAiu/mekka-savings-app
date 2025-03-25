import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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

    setState(() {
      nickname = userDoc['nickname'];
      bio = userDoc['bio'] ?? "Коплю на Умру с друзьями 🕋";
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
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(
                  {key: value},
                  SetOptions(merge: true),
                );
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                children: [
                  // 🌙 Аят / хадис
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "“Поистине, лучшие дела — постоянные,\nпусть и малые.” (Хадис)",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),

                  // 👳 Аватар
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.teal.shade100,
                    child: SvgPicture.asset('assets/kaaba.svg', height: 40),
                  ),

                  SizedBox(height: 12),
                  Text(
                    user?.displayName ?? "Без имени",
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(user?.email ?? '', style: GoogleFonts.nunito(color: Colors.grey[700])),

                  SizedBox(height: 8),
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
                  _statRow("💰 Всего накоплено", "${totalSaved.toStringAsFixed(0)} тг"),
                  _statRow("🧾 Кол-во взносов", "$transactionsCount"),

                  SizedBox(height: 30),

                  // 🫂 Кнопки
                  _menuButton(Icons.group_outlined, "Мои друзья", FriendsScreen()),
                  _menuButton(Icons.flag_outlined, "Общие цели", MySharedGoalsScreen()),
                  _menuButton(Icons.add_circle_outline, "Создать цель", CreateSharedGoalScreen()),

                  SizedBox(height: 30),

                  // 🚪 Выйти
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text("Выйти", style: GoogleFonts.nunito(fontSize: 16)),
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
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 15, color: Colors.grey[800])),
          Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15)),
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
}