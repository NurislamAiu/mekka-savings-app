import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/shared_goal_provider.dart';

class ConfirmParticipationButton extends StatelessWidget {
  final String goalId;
  final List members;
  final SharedGoalProvider provider;

  const ConfirmParticipationButton({
    super.key,
    required this.goalId,
    required this.members,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isConfirmed = _isUserConfirmed(members, currentUserId);

    if (isConfirmed) return const SizedBox.shrink();

    return ElevatedButton.icon(
      onPressed: () async {
        await provider.confirmParticipation(goalId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Участие подтверждено 🌙")),
          );
        }
      },
      icon: const Icon(Icons.check_circle, color: Colors.white),
      label: const Text("Подтвердить участие"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  bool _isUserConfirmed(List members, String uid) {
    final user = members.firstWhere(
          (m) => m['uid'] == uid,
      orElse: () => <String, dynamic>{},
    );
    return user['confirmed'] == true;
  }
}