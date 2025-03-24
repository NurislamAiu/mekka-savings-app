import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../utils/goal_helper.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _forecastDate;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GoalProvider>(context, listen: false);
    provider.loadGoal();
    provider.loadGoal().then((_) async {
      final forecast = await provider.calculateForecastDate();
      setState(() {
        _forecastDate = forecast;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);

    if (goalProvider.goal == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Накопление")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final goal = goalProvider.goal!;
    final plan = GoalHelper.calculatePlan(goal);

    void _showAddDialog(BuildContext context) {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      final amountController = TextEditingController();
      final noteController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Добавить взнос"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Сумма (тг)"),
              ),
              TextField(
                controller: noteController,
                decoration: InputDecoration(labelText: "Комментарий"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                final note = noteController.text;
                if (amount > 0) {
                  await goalProvider.addTransaction(amount, note);
                  Navigator.pop(context);
                }
              },
              child: Text("Добавить"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(goal.title), actions: [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CalendarScreen(userId: 'testUser'),
              ),
            );
          },
        ),
      ],),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: goalProvider.progress,
              minHeight: 15,
            ),
            SizedBox(height: 10),
            Text(
              '${goal.savedAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} тг',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'До цели осталось: ${goal.targetAmount - goal.savedAmount} тг\nДо ${goal.deadline.difference(DateTime.now()).inDays} дней',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 50),
            Text("📊 План накоплений:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Ежедневно: ${plan['perDay'].toStringAsFixed(0)} тг"),
            Text("Еженедельно: ${plan['perWeek'].toStringAsFixed(0)} тг"),
            Text("Ежемесячно: ${plan['perMonth'].toStringAsFixed(0)} тг"),
            SizedBox(height: 10),
            Text("Осталось дней: ${plan['daysLeft']}"),
            Text("До цели: ${plan['amountLeft'].toStringAsFixed(0)} тг"),

            if (_forecastDate != null)
              Text(
                "📅 При текущем темпе ты достигнешь цели к: "
                    "${DateFormat('dd MMMM yyyy', 'ru').format(_forecastDate!)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )
            else
              Text("⚠️ Недостаточно данных для прогноза"),
          ],
        ),
      ),
    );
  }
}