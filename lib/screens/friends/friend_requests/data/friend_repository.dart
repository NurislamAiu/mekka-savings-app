import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<List<Map<String, dynamic>>> fetchFriendRequests() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final List<dynamic> requestUIDs = userDoc.data()?['friendRequests'] ?? [];

    final futures = requestUIDs.map((friendUid) async {
      final doc = await _firestore.collection('users').doc(friendUid).get();
      if (!doc.exists) return null;
      return {
        'uid': friendUid,
        'nickname': doc['nickname'] ?? '',
        'email': doc['email'] ?? '',
      };
    }).toList();

    final result = await Future.wait(futures);
    return result.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> acceptFriend(String friendUid) async {
    final uid = currentUserId;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);
    final friendRef = _firestore.collection('users').doc(friendUid);

    await userRef.update({
      'friends': FieldValue.arrayUnion([friendUid]),
      'friendRequests': FieldValue.arrayRemove([friendUid]),
    });

    await friendRef.update({
      'friends': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> declineFriend(String friendUid) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'friendRequests': FieldValue.arrayRemove([friendUid]),
    });
  }
}