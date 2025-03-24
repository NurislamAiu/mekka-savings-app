import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Получение данных цели
  Stream<DocumentSnapshot> getGoalStream(String userId) {
    return _db.collection('users').doc(userId).collection('goals').doc('mekkaTrip').snapshots();
  }

  // Добавление транзакции
  Future<void> addTransaction(String userId, double amount, String note) async {
    final transactionRef = _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc('mekkaTrip')
        .collection('transactions');

    final goalRef = _db.collection('users').doc(userId).collection('goals').doc('mekkaTrip');

    // Добавить новую транзакцию
    await transactionRef.add({
      'amount': amount,
      'note': note,
      'date': Timestamp.now(),
    });

    // Обновить сохранённую сумму
    await goalRef.update({
      'savedAmount': FieldValue.increment(amount),
    });
  }
}