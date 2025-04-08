import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../presentation/goal_provider.dart';
import 'fancy_input_field.dart';

void showAddContributionSheet(BuildContext context, ConfettiController confettiController) {
  final goalProvider = Provider.of<GoalProvider>(context, listen: false);
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  bool isSubmitting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset('assets/kaaba.svg', height: 48),
                const SizedBox(height: 10),
                Text(
                  "Каждый вклад — приближение к Умре 🕋",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[900]),
                ),
                const SizedBox(height: 24),
                FancyInputField(controller: amountController, icon: Icons.monetization_on_outlined, hint: "Сумма (тг)", keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                FancyInputField(controller: noteController, icon: Icons.edit_note_outlined, hint: "Комментарий (необязательно)"),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(
                      isSubmitting ? "Добавление..." : "Добавить взнос",
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                      final amount = double.tryParse(amountController.text) ?? 0;
                      final note = noteController.text.trim();

                      if (amount > 0) {
                        setModalState(() => isSubmitting = true);
                        await goalProvider.addTransaction(amount, note);
                        Navigator.pop(context);
                        confettiController.play();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}