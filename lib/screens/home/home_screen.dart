import 'package:flutter/material.dart';
import 'package:mekka_savings_app/screens/home/widgets/add_contribution_sheet.dart';
import 'package:mekka_savings_app/screens/home/widgets/goal_reached_dialog.dart';
import 'package:mekka_savings_app/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

import '../../../../models/goal_model.dart';
import '../../../../providers/goal_provider.dart';
import '../../../../core/goal_helper.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/plan_rows.dart';
import 'widgets/shimmer_widgets.dart';
import 'widgets/goal_status_text.dart';
import 'widgets/ayah_section.dart';
import 'widgets/confetti_widget.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _forecastDate;
  late ConfettiController _confettiController;
  bool _goalReachedShown = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    final provider = Provider.of<GoalProvider>(context, listen: false);
    provider.loadGoals().then((_) async {
      final forecast = await provider.calculateForecastDate();
      if (mounted) {
        setState(() => _forecastDate = forecast);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildMainContent({required bool isLoading, GoalModel? goal}) {
    final plan = goal != null ? GoalHelper.calculatePlan(goal) : {};
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
              ? ShimmerBox(width: 150, height: 20)
              : const Text(
                "План накоплений",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          const SizedBox(height: 10),
          isLoading
              ? Column(children: [ShimmerRow(), ShimmerRow(), ShimmerRow()])
              : Column(
                children: [
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
                  PlanRow(
                    label: "Осталось дней",
                    value: "${plan['daysLeft'] ?? 0}",
                  ),
                ],
              ),
          if (!isLoading && _forecastDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                "📅 Прогноз: ${DateFormat('dd MMMM yyyy', 'ru').format(_forecastDate!)}",
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
    final provider = Provider.of<GoalProvider>(context);
    final goal = provider.currentGoal;

    if (goal != null &&
        !_goalReachedShown &&
        goal.savedAmount >= goal.targetAmount) {
      _goalReachedShown = true;
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) showGoalReachedDialog(context);
      });
    }

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
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: _buildMainContent(isLoading: goal == null, goal: goal),
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
              child: IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ProfileScreen()));
              }, icon: Icon(Icons.person),),
            ),
          )
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
