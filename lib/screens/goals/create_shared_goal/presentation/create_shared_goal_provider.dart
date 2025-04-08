import 'package:flutter/material.dart';
import '../domain/create_shared_goal_use_case.dart';

class CreateSharedGoalProvider with ChangeNotifier {
  final CreateSharedGoalUseCase useCase;

  CreateSharedGoalProvider({required this.useCase});

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  DateTime? selectedDate;

  List<Map<String, dynamic>> allFriends = [];
  Set<String> selectedUIDs = {};

  bool isLoading = false;
  String? errorMessage;

  void setDeadline(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void toggleFriend(String uid) {
    if (selectedUIDs.contains(uid)) {
      selectedUIDs.remove(uid);
    } else {
      selectedUIDs.add(uid);
    }
    notifyListeners();
  }

  Future<void> loadFriends() async {
    allFriends = await useCase.getFriends();
    notifyListeners();
  }

  Future<bool> createGoal() async {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final deadline = selectedDate;

    if (title.isEmpty || amount <= 0 || deadline == null) {
      errorMessage = "Заполните все поля корректно";
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await useCase.createGoal(
        title: title,
        amount: amount,
        deadline: deadline,
        selectedUIDs: selectedUIDs,
        allFriends: allFriends,
      );
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = "Ошибка при создании цели";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }
}