import 'package:flutter/material.dart';
import '../../../widgets/close_screen_button.dart';
import 'wigdets/create_shared_goal_form.dart';

class CreateSharedGoalScreen extends StatelessWidget {
  const CreateSharedGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: const [
          _Background(),
          SafeArea(
            child: CreateSharedGoalForm(),
          ),
          CloseScreenButton(),
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