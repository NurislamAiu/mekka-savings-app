import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final emailController = TextEditingController();
  String statusMessage = '';
  List<Map<String, dynamic>> friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final friendUIDs = List<String>.from(doc.data()?['friends'] ?? []);

    List<Map<String, dynamic>> loaded = [];
    for (String uid in friendUIDs) {
      final friendDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (friendDoc.exists) {
        loaded.add({
          'uid': uid,
          'nickname': friendDoc['nickname'] ?? '',
          'email': friendDoc['email'] ?? '',
        });
      }
    }

    setState(() {
      friends = loaded;
    });
  }

  Future<void> _addFriend() async {
    final email = emailController.text.trim();

    if (email.isEmpty || email == user?.email) {
      setState(() => statusMessage = "❗ Введи email другого пользователя");
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) {
      setState(() => statusMessage = "😕 Пользователь не найден");
      return;
    }

    final friendId = query.docs.first.id;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'friends': FieldValue.arrayUnion([friendId])
    });

    setState(() {
      emailController.clear();
      statusMessage = "✅ Друг добавлен!";
    });

    _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        title: Text("🫂 Мои друзья", style: GoogleFonts.cairo()),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email друга",
                suffixIcon: IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: _addFriend,
                ),
              ),
            ),
            SizedBox(height: 10),
            if (statusMessage.isNotEmpty)
              Text(
                statusMessage,
                style: GoogleFonts.nunito(
                  color: statusMessage.contains("✅") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Divider(height: 40),
            Expanded(
              child: friends.isEmpty
                  ? Center(child: Text("Нет добавленных друзей", style: GoogleFonts.nunito()))
                  : ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Icon(Icons.person, color: Colors.teal[800]),
                    ),
                    title: Text("@${friend['nickname']}", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                    subtitle: Text(friend['email']),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}