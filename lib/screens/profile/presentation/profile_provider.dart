import 'package:flutter/material.dart';
import '../domain/profile_use_case.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileUseCase useCase;

  ProfileProvider({required this.useCase});

  String? nickname;
  String? bio;
  int transactionsCount = 0;
  double totalSaved = 0;
  bool isLoading = true;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    final userData = await useCase.getUserInfo();
    final goalData = await useCase.getGoalInfo('mekkaTrip');
    final txCount = await useCase.getTransactionCount('mekkaTrip');

    nickname = userData['nickname'] ?? '';
    bio = userData['bio'] ?? 'Коплю на Умру 🕋';
    totalSaved = (goalData['savedAmount'] ?? 0).toDouble();
    transactionsCount = txCount;

    isLoading = false;
    notifyListeners();
  }
}