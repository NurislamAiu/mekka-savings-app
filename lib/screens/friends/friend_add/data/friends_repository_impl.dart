import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/friend_user.dart';
import '../domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<FriendUser?> searchUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    return FriendUser(
      uid: snapshot.docs.first.id,
      nickname: data['nickname'],
      email: data['email'],
    );
  }

  @override
  Future<String> checkFriendStatus(String uid) async {
    final currentUid = _auth.currentUser!.uid;
    if (uid == currentUid) return 'self';

    final myDoc = await _firestore.collection('users').doc(currentUid).get();
    final friends = List<String>.from(myDoc.data()?['friends'] ?? []);
    final requests = List<String>.from(myDoc.data()?['friendRequests'] ?? []);

    if (friends.contains(uid)) return 'already_friends';
    if (requests.contains(uid)) return 'request_sent';
    return 'can_add';
  }

  @override
  Future<void> sendFriendRequest(String targetUid) async {
    final myUid = _auth.currentUser!.uid;

    final doc = await _firestore.collection('users').doc(targetUid).get();
    final friends = List<String>.from(doc.data()?['friends'] ?? []);
    final requests = List<String>.from(doc.data()?['friendRequests'] ?? []);

    if (friends.contains(myUid) || requests.contains(myUid)) return;

    await _firestore.collection('users').doc(targetUid).update({
      'friendRequests': FieldValue.arrayUnion([myUid]),
    });
  }
}