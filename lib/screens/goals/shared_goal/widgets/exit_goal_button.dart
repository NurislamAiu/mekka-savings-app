import 'package:flutter/material.dart';
import '../presentation/shared_goal_provider.dart';

class ExitGoalButton extends StatelessWidget {
  final String goalId;
  final SharedGoalProvider provider;

  const ExitGoalButton({
    super.key,
    required this.goalId,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _confirmExitDialog(context),
      icon: const Icon(Icons.exit_to_app),
      label: const Text("Выйти из цели"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  void _confirmExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Подтверждение"),
        content: const Text("Вы уверены, что хотите выйти из общей цели?"),
        actions: [
          TextButton(
            child: const Text("Отмена"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Выйти", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop(); // Закрыть диалог

              await provider.exitGoal(goalId);

              if (context.mounted) {
                Navigator.of(context).pop(); // Выйти с экрана
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Вы вышли из цели 🚪")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}