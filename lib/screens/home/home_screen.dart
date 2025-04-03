import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mekka_savings_app/models/goal_model.dart';
import 'package:mekka_savings_app/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/daily_ayahs.dart';
import '../../providers/goal_provider.dart';
import '../../core/goal_helper.dart';

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
  final ayah = dailyAyahs[DateTime.now().day % dailyAyahs.length];
  final todayAyah = todayAyahsList[DateTime.now().day % todayAyahsList.length];

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

  // Отображение нижнего листа для добавления вклада
  void showDeluxeBottomSheet(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
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
                    _fancyField(
                      controller: amountController,
                      icon: Icons.monetization_on_outlined,
                      hint: "Сумма (тг)",
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 14),
                    _fancyField(
                      controller: noteController,
                      icon: Icons.edit_note_outlined,
                      hint: "Комментарий (необязательно)",
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: isSubmitting
                            ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(Icons.check_circle_outline, color: Colors.white),
                        label: Text(
                          isSubmitting ? "Добавление..." : "Добавить взнос",
                          style: GoogleFonts.nunito(
                              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          elevation: 5,
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                            _confettiController.play();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      todayAyah,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Диалог достижения цели
  void _showGoalReachedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'GoalReached',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/kaaba.svg', height: 60),
                  SizedBox(height: 20),
                  Text(
                    "🎉 Поздравляем!",
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Ты достиг своей цели! 🕋\nАллах примет твои старания и намерения.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.favorite, color: Colors.white),
                    label: Text("Альхамдулиллях", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // Единый layout для основного контента и shimmer‑эффектов
  Widget _buildMainContent({required bool isLoading, GoalModel? goal, required BuildContext context}) {
    final plan = (goal != null) ? GoalHelper.calculatePlan(goal) : {};
    final status = (goal != null) ? GoalHelper.getProgressStatus(goal) : '';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя строка: логотип и кнопка профиля
            Row(
              children: [
                isLoading
                    ? _shimmerBox(width: 32, height: 32)
                    : SvgPicture.asset('assets/kaaba.svg', height: 32),
                SizedBox(width: 12),
                isLoading
                    ? _shimmerBox(width: 150, height: 20)
                    : Text(
                  "Накопление на Умру",
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                Spacer(),
                isLoading
                    ? _shimmerBox(width: 32, height: 32)
                    : IconButton(
                  icon: Icon(Icons.person_outline, size: 32),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Отображение аятов
            isLoading
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: double.infinity, height: 18),
                SizedBox(height: 8),
                _shimmerBox(width: double.infinity, height: 14),
                SizedBox(height: 4),
                _shimmerBox(width: 100, height: 12),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ayah["arabic"] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Amiri',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '"${ayah["ru"]}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 4),
                Text(
                  ayah["source"] ?? '',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Карточка прогресса
            isLoading
                ? _shimmerCard(height: 100)
                : Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Прогресс",
                        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: goal!.savedAmount / goal.targetAmount,
                        minHeight: 14,
                        backgroundColor: Colors.grey[300],
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${goal!.savedAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} тг",
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // План накоплений
            isLoading
                ? _shimmerBox(width: 150, height: 20)
                : Text("План накоплений",
                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            isLoading
                ? Column(
              children: [
                _shimmerRow(),
                _shimmerRow(),
                _shimmerRow(),
              ],
            )
                : Column(
              children: [
                _planRow("Ежедневно", "${plan['perDay'].toStringAsFixed(0)} тг"),
                _planRow("Еженедельно", "${plan['perWeek'].toStringAsFixed(0)} тг"),
                _planRow("Ежемесячно", "${plan['perMonth'].toStringAsFixed(0)} тг"),
                _planRow("До цели", "${plan['amountLeft'].toStringAsFixed(0)} тг"),
                _planRow("Осталось дней", "${plan['daysLeft']}"),
              ],
            ),
            // Прогноз даты (если имеется)
            if (!isLoading && _forecastDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "📅 Прогноз: ${DateFormat('dd MMMM yyyy', 'ru').format(_forecastDate!)}",
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.teal[900]),
                ),
              ),
            SizedBox(height: 10),
            // Статус накоплений
            isLoading
                ? _shimmerBox(width: 100, height: 18)
                : Text(
              status,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: status.contains("✅")
                    ? Colors.green
                    : status.contains("⚠️")
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer‑виджеты
  Widget _shimmerBox({double width = double.infinity, double height = 16}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _shimmerCard({double height = 120}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _shimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _shimmerBox(width: 140, height: 14),
          _shimmerBox(width: 80, height: 14),
        ],
      ),
    );
  }

  Widget _shimmerButton() {
    return Shimmer.fromColors(
      baseColor: Colors.teal.shade200,
      highlightColor: Colors.teal.shade100,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Оформление текстового поля с иконкой
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

  // Оформление строки плана накоплений
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

    if (goal != null && !_goalReachedShown && goal.savedAmount >= goal.targetAmount) {
      _goalReachedShown = true;
      _confettiController.play();
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _showGoalReachedDialog(context);
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Фоновый градиент
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
            child: goal == null
                ? _buildMainContent(isLoading: true, goal: null, context: context)
                : _buildMainContent(isLoading: false, goal: goal, context: context),
          ),
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
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Добавить взнос",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}