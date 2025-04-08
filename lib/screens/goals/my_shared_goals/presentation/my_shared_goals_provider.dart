import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../domain/my_shared_goal_use_case.dart';

class MySharedGoalsProvider with ChangeNotifier {
  final MySharedGoalUseCase useCase;
  final _auth = FirebaseAuth.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> sharedGoals = [];

  MySharedGoalsProvider({required this.useCase});

  Future<void> loadSharedGoals() async {
    isLoading = true;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    sharedGoals = await useCase.getUserSharedGoals(uid);
    isLoading = false;
    notifyListeners();
  }
}