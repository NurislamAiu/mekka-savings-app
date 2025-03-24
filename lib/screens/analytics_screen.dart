import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/goal_model.dart';

class AnalyticsScreen extends StatefulWidget {
  final String userId;

  AnalyticsScreen({required this.userId});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, double> dailyData = {};
  Map<String, double> monthlyData = {};
  bool isLoading = true;
  List<QueryDocumentSnapshot> transactionDocs = [];
  GoalModel? goal;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final goalDoc = await FirebaseFirestore.instance
        .collection('goals')
        .doc('mekkaTrip')
        .get();

    final goalData = goalDoc.data();
    if (goalData == null) return;

    goal = GoalModel.fromMap(goalData);

    final snapshot = await FirebaseFirestore.instance
        .collection('goals')
        .doc('mekkaTrip')
        .collection('transactions')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('date', descending: false)
        .get();

    transactionDocs = snapshot.docs;

    final now = DateTime.now();
    Map<String, double> tempDaily = {};
    Map<String, double> tempMonthly = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final amount = (data['amount'] ?? 0).toDouble();

      final dayKey = DateFormat('dd.MM').format(date);
      if (now.difference(date).inDays <= 6) {
        tempDaily[dayKey] = (tempDaily[dayKey] ?? 0) + amount;
      }

      final monthKey = DateFormat('MMM yyyy', 'ru').format(date);
      tempMonthly[monthKey] = (tempMonthly[monthKey] ?? 0) + amount;
    }

    setState(() {
      dailyData = tempDaily;
      monthlyData = tempMonthly;
      isLoading = false;
    });
  }

  List<BarChartGroupData> _buildBarData(Map<String, double> dataMap) {
    final sortedKeys = dataMap.keys.toList()..sort();
    final values = dataMap.values.toList();
    final avg = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0;

    return List.generate(sortedKeys.length, (index) {
      final key = sortedKeys[index];
      final value = dataMap[key] ?? 0;

      Color color;
      if (value < avg * 0.5) {
        color = Colors.lightBlue.shade100;
      } else if (value < avg * 1.2) {
        color = Colors.blueAccent;
      } else {
        color = Colors.green;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 16,
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  Widget _buildBarChart(Map<String, double> dataMap, String title) {
    if (dataMap.isEmpty) return Text("Нет данных");

    final sortedKeys = dataMap.keys.toList()..sort();
    final spots = _buildBarData(dataMap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: spots,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: 10000),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < sortedKeys.length) {
                        return Text(sortedKeys[index], style: TextStyle(fontSize: 10));
                      }
                      return Text('');
                    },
                  ),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: dataMap.values.isEmpty ? 0 : dataMap.values.reduce((a, b) => a + b) / dataMap.length,
                    color: Colors.redAccent,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) => "Среднее",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  List<FlSpot> _buildDeviationGraph(List<QueryDocumentSnapshot> docs, GoalModel goal) {
    List<FlSpot> points = [];

    final startDate = docs.first['date'].toDate();
    final endDate = goal.deadline;
    final totalDays = endDate.difference(startDate).inDays;

    double saved = 0;

    for (int i = 0; i < docs.length; i++) {
      final data = docs[i];
      final date = (data['date'] as Timestamp).toDate();
      final amount = (data['amount'] ?? 0).toDouble();
      saved += amount;

      final daysPassed = date.difference(startDate).inDays;
      final expected = goal.targetAmount * (daysPassed / totalDays);
      final deviation = saved - expected;

      points.add(FlSpot(daysPassed.toDouble(), deviation));
    }

    return points;
  }

  Widget buildDeviationChart(List<FlSpot> spots) {
    if (spots.isEmpty) return Text("Недостаточно данных");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📉 Отклонение от плана", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blueAccent,
                  dotData: FlDotData(show: false),
                ),
              ],
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((e) {
                    return LineTooltipItem(
                      "${e.y >= 0 ? '🔼 +' : '🔽 '}${e.y.toStringAsFixed(0)} тг",
                      TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📊 Аналитика")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBarChart(dailyData, "📅 Взносы за последние 7 дней"),
            _buildBarChart(monthlyData, "🗓 Взносы по месяцам"),
            if (goal != null && transactionDocs.isNotEmpty)
              buildDeviationChart(_buildDeviationGraph(transactionDocs, goal!)),
          ],
        ),
      ),
    );
  }
}