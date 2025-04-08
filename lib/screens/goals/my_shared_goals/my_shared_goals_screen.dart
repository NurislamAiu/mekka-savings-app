import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekka_savings_app/screens/goals/my_shared_goals/presentation/my_shared_goals_provider.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/close_screen_button.dart';
import '../create_my_goal/create_my_goal_screen.dart';
import '../create_shared_goal/create_shared_goal_screen.dart';
import 'widgets/shared_goal_card.dart';
import 'widgets/shared_goal_shimmer.dart';
import 'widgets/shared_goal_success_dialog.dart';

class MySharedGoalsScreen extends StatefulWidget {
  const MySharedGoalsScreen({super.key});

  @override
  State<MySharedGoalsScreen> createState() => _MySharedGoalsScreenState();
}

class _MySharedGoalsScreenState extends State<MySharedGoalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MySharedGoalsProvider>().loadSharedGoals());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MySharedGoalsProvider>();
    final goals = provider.sharedGoals;

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
            child: RefreshIndicator(
              onRefresh: () => provider.loadSharedGoals(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: Row(
                      children: [
                        SvgPicture.asset('assets/kaaba.svg', height: 32),
                        const SizedBox(width: 8),
                        Text(
                          "Цели",
                          style: GoogleFonts.cairo(
                            color: Colors.brown[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: provider.isLoading
                        ? const SharedGoalShimmer()
                        : goals.isEmpty
                        ? Center(
                      child: Text(
                        "У тебя пока нет общих целей 😌",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return SharedGoalCard(goal: goal);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const CloseScreenButton(),
        ],
      ),

      // ➕ Кнопки добавления целей
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'My Goal',
            backgroundColor: Colors.white,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateMyGoalScreen()),
              );

              if (result == true) {
                await provider.loadSharedGoals();
                showSharedGoalSuccessDialog(context);
              }
            },
            child: const Icon(Icons.person, size: 24, color: Colors.teal),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'Shared Goal',
            backgroundColor: Colors.white,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateSharedGoalScreen()),
              );

              if (result == true) {
                await provider.loadSharedGoals();
                showSharedGoalSuccessDialog(context);
              }
            },
            child: const Icon(Icons.people, size: 24, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}