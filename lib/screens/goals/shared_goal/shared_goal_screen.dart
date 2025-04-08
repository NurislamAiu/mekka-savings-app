import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekka_savings_app/screens/goals/shared_goal/presentation/shared_goal_provider.dart';
import 'package:provider/provider.dart';
import '../../../widgets/close_screen_button.dart';
import 'widgets/confirm_participation_button.dart';
import 'widgets/exit_goal_button.dart';
import 'widgets/shared_goal_members_list.dart';
import 'widgets/shared_goal_progress.dart';
import 'widgets/shared_goal_shimmer.dart';

class SharedGoalScreen extends StatelessWidget {
  final String goalId;
  const SharedGoalScreen({required this.goalId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Consumer<SharedGoalProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return const SharedGoalShimmer();

                  if (provider.goalData == null) {
                    return const Center(child: Text("❗ Цель не найдена"));
                  }

                  final goal = provider.goalData!;
                  final progress = (goal['savedAmount'] ?? 0) / (goal['targetAmount'] ?? 1);
                  final members = provider.members;

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/kaaba.svg', height: 40),
                          const SizedBox(width: 10),
                          Text(
                            goal['title'] ?? 'Общая цель',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SharedGoalProgress(
                        progress: progress,
                        savedAmount: (goal['savedAmount'] ?? 0).toInt(),
                        targetAmount: (goal['targetAmount'] ?? 1).toInt(),
                      ),

                      const SizedBox(height: 12),

                      ConfirmParticipationButton(
                        goalId: goalId,
                        members: members,
                        provider: provider,
                      ),

                      const SizedBox(height: 24),

                      SharedGoalMembersList(members: members),

                      const SizedBox(height: 24),

                      ExitGoalButton(
                        goalId: goalId,
                        provider: provider,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        '“Аллах вместе с теми, кто проявляет терпение.” (Сура Аль-Бакара 153)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const CloseScreenButton(),
          ],
        ),
    );
  }
}