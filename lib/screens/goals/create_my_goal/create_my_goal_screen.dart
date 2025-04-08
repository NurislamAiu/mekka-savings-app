import 'package:flutter/material.dart';
import 'package:mekka_savings_app/screens/goals/create_my_goal/widgets/create_my_goal_form.dart';

import '../../../widgets/close_screen_button.dart';

class CreateMyGoalScreen extends StatelessWidget {
  const CreateMyGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          const SafeArea(child: CreateMyGoalForm()),
          const CloseScreenButton(),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}