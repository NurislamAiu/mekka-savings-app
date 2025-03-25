import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SharedGoalProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  bool isLoading = true;

  Map<String, dynamic>? goalData;
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> transactions = [];

  /// Загрузить общую цель
  Future<void> loadSharedGoal(String goalId) async {
    isLoading = true;
    notifyListeners();

    final docRef = _firestore.collection('sharedGoals').doc(goalId);
    final doc = await docRef.get();

    if (!doc.exists) {
      goalData = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    final data = doc.data();
    if (data == null) {
      goalData = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    // Миграция, если старый формат
    if (data['members'] is Map) {
      await _migrateMembers(docRef, data['members']);
      return loadSharedGoal(goalId);
    }

    goalData = data;
    members = List<Map<String, dynamic>>.from(data['members'] ?? []);

    final txSnapshot = await docRef
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    transactions = txSnapshot.docs.map((doc) => doc.data()).toList();

    isLoading = false;
    notifyListeners();
  }

  /// Добавить вклад
  Future<void> addTransaction(String goalId, double amount, String note, String uid) async {
    final docRef = _firestore.collection('sharedGoals').doc(goalId);

    await docRef.collection('transactions').add({
      'amount': amount,
      'note': note,
      'by': uid,
      'date': Timestamp.now(),
    });

    await docRef.update({
      'savedAmount': FieldValue.increment(amount),
    });

    await loadSharedGoal(goalId); // Обновим данные после добавления
  }

  /// Миграция участников из старого формата
  Future<void> _migrateMembers(DocumentReference docRef, dynamic oldMembers) async {
    if (oldMembers is Map) {
      final converted = oldMembers.entries.map((e) {
        final v = Map<String, dynamic>.from(e.value);
        v['uid'] = e.key;
        return v;
      }).toList();

      await docRef.update({'members': converted});
    } else if (oldMembers is List) {
      // List<String>
      final List<Map<String, dynamic>> converted = [];

      for (String uid in oldMembers) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          converted.add({
            'uid': uid,
            'nickname': userDoc['nickname'] ?? '',
            'email': userDoc['email'] ?? '',
            'role': 'member',
          });
        }
      }

      await docRef.update({'members': converted});
    }
  }
}