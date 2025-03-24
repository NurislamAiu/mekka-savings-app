import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final String userId;

  CalendarScreen({required this.userId});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Map<String, dynamic>>> _groupedTransactions = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('goals')
        .doc('mekkaTrip')
        .collection('transactions')
        .orderBy('date')
        .get();

    Map<DateTime, List<Map<String, dynamic>>> data = {};

    for (var doc in snapshot.docs) {
      final tx = doc.data();
      final date = (tx['date'] as Timestamp).toDate();
      final day = DateTime(date.year, date.month, date.day);

      if (data[day] == null) data[day] = [];

      data[day]!.add({
        'amount': tx['amount'],
        'note': tx['note'],
        'by': tx['by'] ?? 'Не указано',
        'date': date,
      });
    }

    setState(() {
      _groupedTransactions = data;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _groupedTransactions[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Календарь взносов")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text("Выбери дату"))
                : ListView(
              children: _getEventsForDay(_selectedDay!).map((tx) {
                return ListTile(
                  title: Text("${tx['amount']} тг"),
                  subtitle: Text("${tx['note']} — ${tx['by']}"),
                  trailing: Text(DateFormat('HH:mm').format(tx['date'])),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}