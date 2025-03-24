import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/goal_provider.dart';
import '../utils/goal_helper.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  HomeScreen({required this.userId});

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
    _confettiController = ConfettiController(duration: Duration(seconds: 4));

    final provider = Provider.of<GoalProvider>(context, listen: false);
    provider.loadGoal().then((_) async {
      final forecast = await provider.calculateForecastDate();
      if (mounted) {
        setState(() {
          _forecastDate = forecast;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void showDeluxeBottomSheet(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
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
              // 🕋 Иконка
              SvgPicture.asset('assets/kaaba.svg', height: 48),
              SizedBox(height: 10),
              Text(
                "Каждый вклад — приближение к Умре 🕋",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[900],
                ),
              ),
              SizedBox(height: 24),

              // 💰 Сумма
              _fancyField(
                controller: amountController,
                icon: Icons.monetization_on_outlined,
                hint: "Сумма (тг)",
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 14),

              // 📝 Комментарий
              _fancyField(
                controller: noteController,
                icon: Icons.edit_note_outlined,
                hint: "Комментарий (необязательно)",
              ),

              SizedBox(height: 30),

              // ✅ Кнопка
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    "Добавить взнос",
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    elevation: 5,
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final note = noteController.text.trim();

                    if (amount > 0) {
                      await goalProvider.addTransaction(amount, note);
                      Navigator.pop(context);
                      _confettiController.play();
                    }
                  },
                ),
              ),

              SizedBox(height: 20),

              // 📿 Аят
              Text(
                "“Аллах приумножает [награду] тому, кто расходует ради Него...”",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[800])),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoalProvider>(context);
    final goal = provider.goal;

    if (goal == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final plan = GoalHelper.calculatePlan(goal);
    final status = GoalHelper.getProgressStatus(goal);

    if (!_goalReachedShown && goal.savedAmount >= goal.targetAmount) {
      _goalReachedShown = true;
      _confettiController.play();
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("🎉 Поздравляем!"),
              content: Text("Ты достиг своей цели! 🕋"),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Ура!"))],
            ),
          );
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // 🌅 Фон
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🕋 Заголовок и аят
                  Row(
                    children: [
                      SvgPicture.asset('assets/kaaba.svg', height: 32),
                      SizedBox(width: 12),
                      Text(
                        "Накопление на Умру",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () async => await FirebaseAuth.instance.signOut(),
                        icon: Icon(Icons.logout, color: Colors.grey[700]),
                      )
                    ],
                  ),
                  Text(
                    "“И соверши паломничество ради Аллаха…”\n(Сура 2:196)",
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.brown[700]),
                  ),

                  SizedBox(height: 24),

                  // 📊 Прогресс
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Прогресс", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: provider.progress,
                              minHeight: 14,
                              backgroundColor: Colors.grey[300],
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "${goal.savedAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} тг",
                            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 📆 План
                  Text("План накоплений", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _planRow("Ежедневно", "${plan['perDay'].toStringAsFixed(0)} тг"),
                  _planRow("Еженедельно", "${plan['perWeek'].toStringAsFixed(0)} тг"),
                  _planRow("Ежемесячно", "${plan['perMonth'].toStringAsFixed(0)} тг"),
                  _planRow("До цели", "${plan['amountLeft'].toStringAsFixed(0)} тг"),
                  _planRow("Осталось дней", "${plan['daysLeft']}"),

                  if (_forecastDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        "📅 Прогноз: ${DateFormat('dd MMMM yyyy', 'ru').format(_forecastDate!)}",
                        style: GoogleFonts.nunito(fontSize: 14, color: Colors.teal[900]),
                      ),
                    ),

                  SizedBox(height: 10),
                  Text(
                    status,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: status.contains("✅") ? Colors.green : status.contains("⚠️") ? Colors.orange : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🎊 Конфетти
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),

      // 💚 Кнопка взноса
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            onPressed: () => showDeluxeBottomSheet(context),
            icon: Icon(Icons.add, color: Colors.white,),
            label: Text("Добавить взнос", style: GoogleFonts.nunito(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Widget _fancyField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.nunito(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal.shade100),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}