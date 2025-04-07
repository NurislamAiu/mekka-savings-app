import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  List<GoalModel> goals = [];  // Хранение целей текущего пользователя
  List<GoalModel> friendsGoals = [];  // Хранение целей друзей
  GoalModel? currentGoal;  // Текущая выбранная цель

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadGoals() async {
    final goalCollection = FirebaseFirestore.instance.collection('goals');
    final snapshot = await goalCollection.get();

    if (snapshot.docs.isEmpty) {
      await createDefaultGoal();  // Создание стандартной цели, если нет данных
      return loadGoals();  // Перезагрузка после добавления
    }

    goals = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return GoalModel.fromMap(data, doc.id);
    }).toList();

    // Загрузите цели друзей, например, из другой коллекции или базы данных
    await loadFriendsGoals();  // Метод загрузки целей друзей

    currentGoal = goals.isNotEmpty ? goals[0] : null;
    notifyListeners();
  }

  Future<void> createDefaultGoal() async {
    final goalDoc = FirebaseFirestore.instance.collection('goals').doc('mekkaTrip');
    await goalDoc.set({
      'title': 'Путёвка в Мекку для мамы',
      'targetAmount': 1500000,
      'savedAmount': 0,
      'deadline': Timestamp.fromDate(DateTime(2025, 10, 1)),
    });

    // После создания цели перезагрузите список
    loadGoals();
  }

  Future<void> loadFriendsGoals() async {
    // Пример загрузки целей друзей из другой коллекции
    final friendsSnapshot = await FirebaseFirestore.instance.collection('sharedGoals').get();

    friendsGoals = friendsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return GoalModel.fromMap(data, doc.id);
    }).toList();

    notifyListeners();
  }

  void switchGoal(GoalModel goal) {
    currentGoal = goal;
    notifyListeners();
  }

  double get progress => currentGoal == null || currentGoal!.targetAmount == 0
      ? 0
      : currentGoal!.savedAmount / currentGoal!.targetAmount;

  Future<void> addTransaction(double amount, String note) async {
    final user = _auth.currentUser;

    if (currentGoal != null) {
      await FirebaseFirestore.instance
          .collection('goals')
          .doc(currentGoal!.id)
          .collection('transactions')
          .add({
        'amount': amount,
        'note': note,
        'by': user?.email ?? 'Неизвестный',
        'userId': user?.uid ?? '',
        'date': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('goals')
          .doc(currentGoal!.id)
          .update({
        'savedAmount': FieldValue.increment(amount),
      });

      await loadGoals();
    }
  }

  Future<DateTime?> calculateForecastDate() async {
    if (currentGoal == null) return null;

    final txSnapshot = await FirebaseFirestore.instance
        .collection('goals')
        .doc(currentGoal!.id)
        .collection('transactions')
        .orderBy('date')
        .get();

    if (txSnapshot.docs.isEmpty) return null;

    double totalAmount = 0;
    DateTime firstDate = DateTime.now();

    for (int i = 0; i < txSnapshot.docs.length; i++) {
      final data = txSnapshot.docs[i].data();
      totalAmount += (data['amount'] ?? 0).toDouble();

      final txDate = (data['date'] as Timestamp).toDate();
      if (i == 0) firstDate = txDate;
    }

    final daysPassed = DateTime.now().difference(firstDate).inDays.clamp(1, 1000);
    final avgPerDay = totalAmount / daysPassed;

    final amountLeft = (currentGoal!.targetAmount - currentGoal!.savedAmount).clamp(0, double.infinity);
    final estimatedDaysToFinish = (amountLeft / avgPerDay).ceil();

    return DateTime.now().add(Duration(days: estimatedDaysToFinish));
  }
}
