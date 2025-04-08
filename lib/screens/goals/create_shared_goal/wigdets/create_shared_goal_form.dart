import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../presentation/create_shared_goal_provider.dart';
import 'custom_calendar_sheet.dart';
import 'select_friends_list.dart';

class CreateSharedGoalForm extends StatefulWidget {
  const CreateSharedGoalForm({super.key});

  @override
  State<CreateSharedGoalForm> createState() => _CreateSharedGoalFormState();
}

class _CreateSharedGoalFormState extends State<CreateSharedGoalForm> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CreateSharedGoalProvider>().loadFriends();
    });
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final picked = await showCustomCalendarSheet(context);
    if (picked != null) {
      context.read<CreateSharedGoalProvider>().setDeadline(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateSharedGoalProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// Заголовок
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/kaaba.svg', height: 40),
                  const SizedBox(width: 10),
                  Text(
                    "Общая цель с друзьями",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// Название цели
              _cardInput("🎯 Название цели", provider.titleController),
              const SizedBox(height: 16),

              /// Сумма цели
              _cardInput("💰 Сумма цели (тг)", provider.amountController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              /// Календарь дедлайна
              Card(
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
                  onTap: () => _pickDeadline(context),
                ),
              ),
              const SizedBox(height: 24),

              /// Добавление друзей
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "👥 Добавить друзей",
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
              ),
              SelectFriendsList(
                allFriends: provider.allFriends,
                selectedUIDs: provider.selectedUIDs,
                onSelectionChanged: (uid, selected) {
                  provider.toggleFriend(uid);
                },
              ),
              const SizedBox(height: 24),

              /// Ошибка
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              /// Кнопка создания цели
              SizedBox(
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
                  icon: provider.isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    provider.isLoading ? "Создание..." : "Создать общую цель",
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Хадис
              Text(
                '“Аллах помогает Своему рабу, пока тот помогает брату своему.” (Хадис)',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cardInput(String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}