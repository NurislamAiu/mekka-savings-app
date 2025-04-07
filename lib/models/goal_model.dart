import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;  // Уникальный идентификатор для каждой цели
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;

  GoalModel({
    required this.id,  // Идентификатор
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map, String id) {
    return GoalModel(
      id: id,  // Идентификатор из Firestore
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
    );
  }

  // Преобразование модели в Map для записи в Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'deadline': Timestamp.fromDate(deadline),
    };
  }
}