import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/i_shared_goal_repository.dart';

class SharedGoalRepository implements ISharedGoalRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>?> fetchGoal(String goalId) async {
    final doc = await _firestore.collection('sharedGoals').doc(goalId).get();
    return doc.exists ? {...doc.data()!, 'id': doc.id} : null;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTransactions(String goalId) async {
    final snapshot = await _firestore
        .collection('sharedGoals')
        .doc(goalId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  @override
  Future<void> addTransaction(String goalId, double amount, String note, String uid) async {
    final docRef = _firestore.collection('sharedGoals').doc(goalId);
    await docRef.collection('transactions').add({
      'amount': amount,
      'note': note,
      'by': uid,
      'date': Timestamp.now(),
    });
    await docRef.update({'savedAmount': FieldValue.increment(amount)});
  }

  @override
  Future<void> confirmParticipation(String goalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('sharedGoals').doc(goalId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final List membersList = List.from(docSnap['members'] ?? []);
    for (final member in membersList) {
      if (member['uid'] == uid) {
        member['confirmed'] = true;
        break;
      }
    }

    final allConfirmed = membersList.every((m) => m['confirmed'] == true);
    await docRef.update({'members': membersList, 'confirmed': allConfirmed});
  }

  @override
  Future<void> exitGoal(String goalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('sharedGoals').doc(goalId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final membersList = List<Map<String, dynamic>>.from(docSnap['members'] ?? []);
    membersList.removeWhere((m) => m['uid'] == uid);
    final allConfirmed = membersList.isNotEmpty && membersList.every((m) => m['confirmed'] == true);

    await docRef.update({
      'members': membersList,
      'memberUIDs': membersList.map((m) => m['uid']).toList(),
      'confirmed': allConfirmed,
    });
  }
}