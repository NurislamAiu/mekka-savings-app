import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;

  GoalModel({
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
    );
  }
}