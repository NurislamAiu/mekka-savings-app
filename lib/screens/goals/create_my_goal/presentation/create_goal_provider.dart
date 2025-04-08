import 'package:flutter/material.dart';
import '../domain/create_goal_use_case.dart';

class CreateGoalProvider with ChangeNotifier {
  final CreateGoalUseCase useCase;

  CreateGoalProvider({required this.useCase});

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  DateTime? selectedDate;

  bool isLoading = false;
  String? errorMessage;

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void clear() {
    titleController.clear();
    amountController.clear();
    selectedDate = null;
    errorMessage = null;
  }

  Future<bool> createGoal() async {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final deadline = selectedDate;

    if (title.isEmpty || amount <= 0 || deadline == null) {
      errorMessage = "Пожалуйста, заполните все поля корректно";
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await useCase.execute(
        title: title,
        amount: amount,
        deadline: deadline,
      );

      errorMessage = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = "Ошибка при создании цели";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }
}