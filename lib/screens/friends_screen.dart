import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final controller = TextEditingController();

  Map<String, dynamic>? foundUser;
  String status = '';
  bool isSearching = false;

  Future<void> searchUser() async {
    final email = controller.text.trim().toLowerCase();

    if (email == user?.email) {
      setState(() {
        foundUser = null;
        status = 'self';
      });
      return;
    }

    setState(() {
      isSearching = true;
      foundUser = null;
      status = '';
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        foundUser = null;
        status = 'not_found';
        isSearching = false;
      });
      return;
    }

    final data = snapshot.docs.first.data();
    final uid = snapshot.docs.first.id;
    final myDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    final myFriends = List<String>.from(myDoc.data()?['friends'] ?? []);
    final myRequests = List<String>.from(myDoc.data()?['friendRequests'] ?? []);

    setState(() {
      foundUser = {
        'uid': uid,
        'nickname': data['nickname'],
        'email': data['email'],
      };
      isSearching = false;

      if (myFriends.contains(uid)) {
        status = 'already_friends';
      } else if (myRequests.contains(uid)) {
        status = 'request_sent';
      } else {
        status = 'can_add';
      }
    });
  }

  Future<void> sendFriendRequest() async {
    final targetId = foundUser!['uid'];

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'friendRequests': FieldValue.arrayUnion([targetId])
    }, SetOptions(merge: true));

    setState(() {
      status = 'request_sent';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Запрос отправлен 🌙'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _statusWidget() {
    switch (status) {
      case 'self':
        return Text("Это ты 😊", style: GoogleFonts.nunito(color: Colors.grey));
      case 'not_found':
        return Text("Пользователь не найден ❌", style: GoogleFonts.nunito(color: Colors.red));
      case 'already_friends':
        return Text("Уже в друзьях 🫂", style: GoogleFonts.nunito(color: Colors.green));
      case 'request_sent':
        return Text("Запрос уже отправлен 🕊", style: GoogleFonts.nunito(color: Colors.orange));
      case 'can_add':
        return ElevatedButton.icon(
          onPressed: sendFriendRequest,
          icon: Icon(Icons.person_add, color: Colors.white),
          label: Text("Добавить в друзья", style: GoogleFonts.nunito(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      default:
        return SizedBox.shrink();
    }
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Иконка Каабы и заголовок
                  SvgPicture.asset('assets/kaaba.svg', height: 50),
                  SizedBox(height: 10),
                  Text(
                    "Пригласи друзей к Умре 🕋",
                    style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "«Кто указал на благое — тот получит награду подобную награде совершающего это благое» (Хадис)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20),

                  // Поле поиска
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Email друга",
                      prefixIcon: Icon(Icons.search, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onSubmitted: (_) => searchUser(),
                  ),

                  SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: searchUser,
                      child: Text("Найти друга", style: GoogleFonts.nunito(fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Загрузка и результат поиска
                  if (isSearching) CircularProgressIndicator(),

                  if (foundUser != null && !isSearching)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("@${foundUser!['nickname']}", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(foundUser!['email'], style: GoogleFonts.nunito(color: Colors.grey[700])),
                          SizedBox(height: 14),
                          _statusWidget(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Кнопка возврата назад
          Positioned(
            top: 50,
            right: 10,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black, size: 24,),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}