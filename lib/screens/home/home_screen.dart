import 'package:flutter/material.dart';
import 'package:mekka_savings_app/screens/home/presentation/goal_provider.dart';
import 'package:mekka_savings_app/screens/home/widgets/add_contribution_sheet.dart';
import 'package:mekka_savings_app/screens/home/widgets/ayah_section.dart';
import 'package:mekka_savings_app/screens/home/widgets/confetti_widget.dart';
import 'package:mekka_savings_app/screens/home/widgets/goal_progress_card.dart';
import 'package:mekka_savings_app/screens/home/widgets/goal_reached_dialog.dart';
import 'package:mekka_savings_app/screens/home/widgets/goal_status_text.dart';
import 'package:mekka_savings_app/screens/home/widgets/plan_rows.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

import '../../../models/goal_model.dart';
import '../../core/goal_helper.dart';
import '../profile/profile_screen.dart';
import 'widgets/shimmer_widgets.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );

    Future.microtask(() async {
      final provider = context.read<GoalProvider>();
      await provider.loadGoals();

      if (provider.showGoalReached) {
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) showGoalReachedDialog(context);
        });
        provider.markGoalReachedAsShown();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildPlanSection(GoalModel goal) {
    final plan = GoalHelper.calculatePlan(goal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "План накоплений",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        PlanRow(
          label: "Ежедневно",
          value: "${plan['perDay']?.toStringAsFixed(0) ?? 0} тг",
        ),
        PlanRow(
          label: "Еженедельно",
          value: "${plan['perWeek']?.toStringAsFixed(0) ?? 0} тг",
        ),
        PlanRow(
          label: "Ежемесячно",
          value: "${plan['perMonth']?.toStringAsFixed(0) ?? 0} тг",
        ),
        PlanRow(
          label: "До цели",
          value: "${plan['amountLeft']?.toStringAsFixed(0) ?? 0} тг",
        ),
        PlanRow(label: "Осталось дней", value: "${plan['daysLeft'] ?? 0}"),
      ],
    );
  }

  Widget _buildMainContent({
    required bool isLoading,
    required GoalModel? goal,
    required DateTime? forecastDate,
  }) {
    final status = goal != null ? GoalHelper.getProgressStatus(goal) : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AyahSection(isLoading: isLoading),
          const SizedBox(height: 24),
          GoalProgressCard(isLoading: isLoading),
          const SizedBox(height: 20),
          isLoading
              ? Column(children: [ShimmerRow(), ShimmerRow(), ShimmerRow()])
              : _buildPlanSection(goal!),
          if (!isLoading && forecastDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                "📅 Прогноз: ${DateFormat('dd MMMM yyyy', 'ru').format(forecastDate)}",
                style: const TextStyle(color: Colors.teal),
              ),
            ),
          const SizedBox(height: 10),
          GoalStatusText(isLoading: isLoading, status: status),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final goal = provider.currentGoal;
    final forecast = provider.forecastDate;

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
            child: _buildMainContent(
              isLoading: provider.isLoading,
              goal: goal,
              forecastDate: forecast,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: GoalConfettiWidget(controller: _confettiController),
          ),
          Positioned(
            top: 60,
            right: 30,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              radius: 24,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                icon: const Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                () => showAddContributionSheet(context, _confettiController),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Добавить взнос",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
