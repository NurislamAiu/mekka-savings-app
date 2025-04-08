import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../presentation/create_goal_provider.dart';
import 'custom_calendar_bottom_sheet.dart';
import 'goal_input_card.dart';

class CreateMyGoalForm extends StatelessWidget {
  const CreateMyGoalForm({super.key});

  Future<void> _showCalendar(BuildContext context) async {
    final picked = await showCustomCalendar(context);
    if (picked != null) {
      context.read<CreateGoalProvider>().setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateGoalProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/kaaba.svg', height: 40),
              const SizedBox(width: 10),
              Text(
                "Создайте цель",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          GoalInputCard(
            hint: "🎯 Название цели",
            controller: provider.titleController,
          ),
          const SizedBox(height: 16),
          GoalInputCard(
            hint: "💰 Сумма цели (тг)",
            controller: provider.amountController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildDeadlineTile(context, provider),
          const SizedBox(height: 24),
          _buildSubmitButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildDeadlineTile(BuildContext context, CreateGoalProvider provider) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.teal),
        title: Text(
          provider.selectedDate == null
              ? "Выбрать дедлайн"
              : DateFormat('dd MMMM yyyy', 'ru').format(provider.selectedDate!),
          style: GoogleFonts.nunito(),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showCalendar(context),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, CreateGoalProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading
            ? null
            : () async {
          final success = await provider.createGoal();
          if (success && context.mounted) {
            Navigator.pop(context, true);
          }
        },
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: provider.isLoading
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text("Создать цель", style: GoogleFonts.nunito(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}