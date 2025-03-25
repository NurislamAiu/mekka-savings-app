import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final ids = List<String>.from(doc.data()?['friendRequests'] ?? []);

    List<Map<String, dynamic>> result = [];

    for (String uid in ids) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        result.add({
          'uid': uid,
          'nickname': userDoc['nickname'] ?? '',
          'email': userDoc['email'] ?? '',
        });
      }
    }

    setState(() {
      requests = result;
      isLoading = false;
    });
  }

  Future<void> accept(String uid) async {
    final myRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final theirRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await myRef.update({
      'friendRequests': FieldValue.arrayRemove([uid]),
      'friends': FieldValue.arrayUnion([uid]),
    });

    await theirRef.set({
      'friends': FieldValue.arrayUnion([user!.uid]),
    }, SetOptions(merge: true));

    loadRequests();
  }

  Future<void> decline(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'friendRequests': FieldValue.arrayRemove([uid]),
    });

    loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF6EE),
      appBar: AppBar(
        title: Text("📩 Заявки в друзья", style: GoogleFonts.cairo()),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? Center(child: Text("Нет новых заявок", style: GoogleFonts.nunito()))
          : ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final r = requests[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Icon(Icons.person, color: Colors.teal),
              ),
              title: Text("@${r['nickname']}", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
              subtitle: Text(r['email']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => accept(r['uid']),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => decline(r['uid']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}