import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CreateSharedGoalScreen extends StatefulWidget {
  const CreateSharedGoalScreen({super.key});

  @override
  State<CreateSharedGoalScreen> createState() => _CreateSharedGoalScreenState();
}

class _CreateSharedGoalScreenState extends State<CreateSharedGoalScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _selectedDate;
  List<Map<String, dynamic>> allFriends = [];
  Set<String> selectedUIDs = {};

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final List<dynamic> friendUIDs = userDoc.data()?['friends'] ?? [];

    List<Map<String, dynamic>> loaded = [];

    for (String uid in friendUIDs) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        loaded.add({
          'uid': uid,
          'nickname': doc['nickname'] ?? '',
          'email': doc['email'] ?? '',
        });
      }
    }

    setState(() {
      allFriends = loaded;
    });
  }

  Future<void> _createGoal() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final description = _descController.text.trim();

    if (title.isEmpty || amount <= 0 || _selectedDate == null) return;

    final currentUID = user!.uid;
    final creatorDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();

    final nickname = creatorDoc['nickname'] ?? '';
    final email = creatorDoc['email'] ?? '';

    final members = [
      {
        'uid': currentUID,
        'nickname': nickname,
        'email': email,
        'role': 'admin',
      },
      ...allFriends
          .where((f) => selectedUIDs.contains(f['uid']))
          .map((f) => {
        'uid': f['uid'],
        'nickname': f['nickname'],
        'email': f['email'],
        'role': 'member',
      })
    ];

    await FirebaseFirestore.instance.collection('sharedGoals').add({
      'title': title,
      'description': description,
      'targetAmount': amount,
      'savedAmount': 0,
      'deadline': Timestamp.fromDate(_selectedDate!),
      'createdBy': currentUID,
      'createdAt': Timestamp.now(),
      'members': members,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: Text("🎯 Новая общая цель", style: GoogleFonts.cairo()),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Название цели"),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Сумма (тг)"),
            ),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Описание (необязательно)"),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  _selectedDate == null
                      ? "Выбери дедлайн"
                      : "⏳ До ${DateFormat('dd MMMM yyyy', 'ru').format(_selectedDate!)}",
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Text("📅 Выбрать"),
                )
              ],
            ),
            SizedBox(height: 24),
            Text("👥 Добавь друзей в цель", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            ...allFriends.map((friend) {
              final uid = friend['uid'];
              return CheckboxListTile(
                value: selectedUIDs.contains(uid),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedUIDs.add(uid);
                    } else {
                      selectedUIDs.remove(uid);
                    }
                  });
                },
                title: Text("@${friend['nickname']}"),
                subtitle: Text(friend['email']),
              );
            }).toList(),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createGoal,
                icon: Icon(Icons.check),
                label: Text("Создать цель"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}