import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/goal_model.dart';

class GoalRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? '';
  String get userEmail => _auth.currentUser?.email ?? 'Неизвестный';

  Future<List<GoalModel>> fetchGoals() async {
    final snapshot = await _firestore.collection('goals').get();
    return snapshot.docs.map((doc) => GoalModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> createDefaultGoal() async {
    await _firestore.collection('goals').doc('mekkaTrip').set({
      'title': 'Путёвка в Мекку для мамы',
      'targetAmount': 1500000,
      'savedAmount': 0,
      'deadline': Timestamp.fromDate(DateTime(2025, 10, 1)),
    });
  }

  Future<void> addTransaction(String goalId, double amount, String note) async {
    await _firestore.collection('goals').doc(goalId).collection('transactions').add({
      'amount': amount,
      'note': note,
      'by': userEmail,
      'userId': userId,
      'date': Timestamp.now(),
    });

    await _firestore.collection('goals').doc(goalId).update({
      'savedAmount': FieldValue.increment(amount),
    });
  }

  Future<List<Map<String, dynamic>>> fetchTransactions(String goalId) async {
    final snapshot = await _firestore
        .collection('goals')
        .doc(goalId)
        .collection('transactions')
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<GoalModel>> fetchFriendsGoals() async {
    final friendsSnapshot = await _firestore.collection('sharedGoals').get();

    return friendsSnapshot.docs.map((doc) {
      return GoalModel.fromMap(doc.data(), doc.id);
    }).toList();
  }
}