import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGoalRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createGoal({
    required String title,
    required double amount,
    required DateTime deadline,
  }) async {
    await _firestore.collection('goals').add({
      'title': title,
      'targetAmount': amount,
      'deadline': Timestamp.fromDate(deadline),
      'savedAmount': 0,
      'createdAt': Timestamp.now(),
    });
  }
}