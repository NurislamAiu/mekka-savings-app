import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateSharedGoalRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    final user = _auth.currentUser!;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final List<dynamic> friendUIDs = userDoc.data()?['friends'] ?? [];

    List<Map<String, dynamic>> friends = [];

    for (String uid in friendUIDs) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        friends.add({
          'uid': uid,
          'nickname': doc['nickname'] ?? '',
          'email': doc['email'] ?? '',
        });
      }
    }

    return friends;
  }

  Future<void> createSharedGoal({
    required String title,
    required double amount,
    required DateTime deadline,
    required Set<String> selectedUIDs,
    required List<Map<String, dynamic>> allFriends,
  }) async {
    final user = _auth.currentUser!;
    final creatorDoc = await _firestore.collection('users').doc(user.uid).get();
    final nickname = creatorDoc['nickname'] ?? '';
    final email = creatorDoc['email'] ?? '';

    final members = [
      {
        'uid': user.uid,
        'nickname': nickname,
        'email': email,
        'role': 'admin',
        'confirmed': true,
      },
      ...allFriends.where((f) => selectedUIDs.contains(f['uid'])).map((f) => {
        'uid': f['uid'],
        'nickname': f['nickname'],
        'email': f['email'],
        'role': 'member',
        'confirmed': false,
      }),
    ];

    await _firestore.collection('sharedGoals').add({
      'title': title,
      'targetAmount': amount,
      'deadline': Timestamp.fromDate(deadline),
      'savedAmount': 0,
      'createdBy': user.uid,
      'members': members,
      'memberUIDs': members.map((m) => m['uid']).toList(),
      'confirmed': false,
      'createdAt': Timestamp.now(),
    });
  }
}