import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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
    setState(() => isLoading = true);
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
      body: Stack(
        children: [
          // 🌅 Фон
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
              onRefresh: loadRequests,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  // 📖 Хадис дня
                  Column(
                    children: [
                      SvgPicture.asset('assets/kaaba.svg', height: 40),
                      SizedBox(height: 8),
                      Text(
                        '“Верующий для верующего подобен зданию, части которого укрепляют друг друга”',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '(Хадис от аль-Бухари и Муслима)',
                        style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),

                  isLoading
                      ? _buildShimmer()
                      : requests.isEmpty
                      ? Column(
                    children: [
                      SizedBox(height: 60),
                      Text(
                        "📭 Пока нет новых заявок",
                        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  )
                      : Column(
                    children: requests.map(_requestCard).toList(),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> req) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.shade100,
            child: Icon(Icons.person, color: Colors.teal),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("@${req['nickname']}",
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(req['email'], style: GoogleFonts.nunito(color: Colors.grey[700])),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_circle, color: Colors.green, size: 32),
            onPressed: () => accept(req['uid']),
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.redAccent, size: 32),
            onPressed: () => decline(req['uid']),
          ),
        ],
      ),
    );
  }

  // ✨ Шиммер-карточки во время загрузки
  Widget _buildShimmer() {
    return Column(
      children: List.generate(3, (_) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 80,
            margin: EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }),
    );
  }
}