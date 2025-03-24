import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  GoalModel? goal;
  final String userId = "testUser";

  final CollectionReference goalRef = FirebaseFirestore.instance
      .collection('users')
      .doc("testUser")
      .collection('goals');

  Future<void> loadGoal() async {
    final doc = await goalRef.doc('mekkaTrip').get();
    if (!doc.exists) {
      await createDefaultGoal();
    }

    final data = doc.data() as Map<String, dynamic>;
    goal = GoalModel.fromMap(data);


    notifyListeners();
  }

  Future<void> createDefaultGoal() async {
    await goalRef.doc('mekkaTrip').set({
      'title': 'Путёвка в Мекку для мамы',
      'targetAmount': 1500000,
      'savedAmount': 0,
      'deadline': Timestamp.fromDate(DateTime(2025, 10, 1)),
    });
  }

  double get progress => goal == null || goal!.targetAmount == 0
      ? 0
      : goal!.savedAmount / goal!.targetAmount;

  Future<void> addTransaction(double amount, String note) async {
    final goalDoc = goalRef.doc('mekkaTrip');

    // 1. Добавляем транзакцию в подколлекцию
    await goalDoc.collection('transactions').add({
      'amount': amount,
      'note': note,
      'by': "Я", // позже заменим на имя пользователя из FirebaseAuth
      'date': Timestamp.now(),
    });

    // 2. Обновляем savedAmount
    await goalDoc.update({
      'savedAmount': FieldValue.increment(amount),
    });

    // 3. Обновляем локальную модель и уведомляем слушателей
    await loadGoal(); // перезагружаем данные
  }


  Future<DateTime?> calculateForecastDate() async {
    final txSnapshot = await goalRef.doc('mekkaTrip')
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

    final amountLeft = (goal!.targetAmount - goal!.savedAmount).clamp(0, double.infinity);
    final estimatedDaysToFinish = (amountLeft / avgPerDay).ceil();

    return DateTime.now().add(Duration(days: estimatedDaysToFinish));
  }
}

