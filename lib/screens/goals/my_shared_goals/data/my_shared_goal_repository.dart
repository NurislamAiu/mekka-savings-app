import 'package:cloud_firestore/cloud_firestore.dart';

class MySharedGoalRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchSharedGoals(String uid) async {
    final snapshot = await _firestore
        .collection('sharedGoals')
        .where('memberUIDs', arrayContains: uid)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }
}