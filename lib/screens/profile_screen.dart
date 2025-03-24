import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int transactionsCount = 0;
  double totalSaved = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Загружаем цель
    final goalDoc = await FirebaseFirestore.instance
        .collection('goals')
        .doc('mekkaTrip')
        .get();

    final goalData = goalDoc.data();
    if (goalData != null) {
      totalSaved = (goalData['savedAmount'] ?? 0).toDouble();
    }

    // Загружаем транзакции
    final txSnapshot = await FirebaseFirestore.instance
        .collection('goals')
        .doc('mekkaTrip')
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();

    transactionsCount = txSnapshot.docs.length;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: Text("👤 Профиль", style: GoogleFonts.cairo()),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal.shade100,
              child: Icon(Icons.person, size: 48, color: Colors.teal),
            ),
            SizedBox(height: 16),
            Text(user?.displayName ?? "Без имени",
                style: GoogleFonts.cairo(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '',
                style: GoogleFonts.nunito(color: Colors.grey[700])),

            Divider(height: 40),

            _profileRow("💰 Всего накоплено", "${totalSaved.toStringAsFixed(0)} тг"),
            _profileRow("🧾 Кол-во взносов", "$transactionsCount"),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.logout),
                label: Text("Выйти", style: GoogleFonts.nunito(fontSize: 16)),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.nunito(fontSize: 16)),
          Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}