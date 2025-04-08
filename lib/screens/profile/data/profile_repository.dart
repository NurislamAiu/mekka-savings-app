import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProfileRepository({
    required this.firestore,
    required this.auth,
  });

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw Exception("User not authenticated");

    final userDoc = await firestore.collection('users').doc(uid).get();
    return userDoc.data() ?? {};
  }

  Future<Map<String, dynamic>> fetchGoalData(String goalId) async {
    final doc = await firestore.collection('goals').doc(goalId).get();
    return doc.data() ?? {};
  }

  Future<int> fetchTransactionCount(String goalId) async {
    final uid = auth.currentUser?.uid;
    final snapshot = await firestore
        .collection('goals')
        .doc(goalId)
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();
    return snapshot.docs.length;
  }
}