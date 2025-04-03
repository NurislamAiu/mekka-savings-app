import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/goal_model.dart';

class AnalyticsScreen extends StatefulWidget {
  final String userId;
  const AnalyticsScreen({required this.userId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, double> dailyData = {};
  Map<String, double> monthlyData = {};
  List<QueryDocumentSnapshot> transactionDocs = [];
  GoalModel? goal;
  bool isLoading = true;

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

    if (!goalDoc.exists) return;

    goal = GoalModel.fromMap(goalDoc.data()!);

    final txSnapshot = await FirebaseFirestore.instance
        .collection('goals')
        .doc('mekkaTrip')
        .collection('transactions')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('date')
        .get();

    transactionDocs = txSnapshot.docs;

    final now = DateTime.now();
    Map<String, double> tempDaily = {};
    Map<String, double> tempMonthly = {};

    for (var doc in txSnapshot.docs) {
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

  Widget _buildChartCard(String title, Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF5E1), Color(0xFFE8F8F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> dataMap) {
    final keys = dataMap.keys.toList()..sort();
    final values = dataMap.values.toList();
    if (values.isEmpty) {
      return Center(child: Text("Нет данных", style: GoogleFonts.nunito()));
    }

    final avg = values.reduce((a, b) => a + b) / values.length;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(keys.length, (i) {
            final value = dataMap[keys[i]]!;
            final color = value < avg * 0.5
                ? Colors.orange.shade200
                : value < avg * 1.2
                ? Colors.teal
                : Colors.green;

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: 14,
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
              showingTooltipIndicators: [0],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  return Text(i < keys.length ? keys[i] : '', style: TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildDeviationChart() {
    if (transactionDocs.isEmpty || goal == null) {
      return Center(child: Text("Нет данных", style: GoogleFonts.nunito()));
    }

    List<FlSpot> spots = [];
    double saved = 0;
    final startDate = transactionDocs.first['date'].toDate();
    final totalDays = goal!.deadline.difference(startDate).inDays;

    for (var doc in transactionDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final amount = (data['amount'] ?? 0).toDouble();
      saved += amount;
      final daysPassed = date.difference(startDate).inDays;
      final expected = goal!.targetAmount * (daysPassed / totalDays);
      final deviation = saved - expected;
      spots.add(FlSpot(daysPassed.toDouble(), deviation));
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.teal[700],
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.teal!.withOpacity(0.1),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                children: [
                  _buildChartCard("📅 Взносы за 7 дней", _buildBarChart(dailyData)),
                  _buildChartCard("🗓 Взносы по месяцам", _buildBarChart(monthlyData)),
                  _buildChartCard("🧭 Отклонение от плана", _buildDeviationChart()),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.close, size: 24,)),
            ),
          )
        ],
      ),
    );
  }
}