import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../models/goal_model.dart';
import '../presentation/goal_provider.dart';

class GoalProgressCard extends StatelessWidget {
  final bool isLoading;

  const GoalProgressCard({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
      );
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer<GoalProvider>(
          builder: (context, provider, child) {
            List<GoalModel> allGoals = [...provider.goals, ...provider.friendsGoals];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Прогресс", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<GoalModel>(
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      value: provider.currentGoal,
                      onChanged: (GoalModel? newGoal) {
                        if (newGoal != null) {
                          provider.switchGoal(newGoal);
                        }
                      },
                      items: allGoals.map<DropdownMenuItem<GoalModel>>((GoalModel goal) {
                        return DropdownMenuItem<GoalModel>(
                          value: goal,
                          child: Text(goal.title),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: provider.currentGoal != null
                        ? provider.currentGoal!.savedAmount / provider.currentGoal!.targetAmount
                        : 0,
                    minHeight: 14,
                    backgroundColor: Colors.grey[300],
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.currentGoal != null
                      ? "${provider.currentGoal!.savedAmount.toStringAsFixed(0)} / ${provider.currentGoal!.targetAmount.toStringAsFixed(0)} тг"
                      : "Цель не выбрана",
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}