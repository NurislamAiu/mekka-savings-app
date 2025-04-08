import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../friend_add/domain/entities/friend_user.dart';
import '../../domain/entities/friend_user.dart';
import '../../domain/repositories/my_friends_repository.dart';

class MyFriendsRepositoryImpl implements MyFriendsRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<List<FriendUser>> getMyFriends() async {
    final user = _auth.currentUser!;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final friendUIDs = List<String>.from(userDoc.data()?['friends'] ?? []);

    List<FriendUser> result = [];

    for (String uid in friendUIDs) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        result.add(FriendUser(
          uid: uid,
          nickname: doc['nickname'] ?? '',
          email: doc['email'] ?? '',
        ));
      }
    }

    return result;
  }
}