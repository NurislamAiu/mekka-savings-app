import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        .collection('goals')
        .doc('mekkaTrip')
        .collection('transactions')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('date')
        .get();

    Map<DateTime, List<Map<String, dynamic>>> data = {};

    for (var doc in snapshot.docs) {
      final tx = doc.data();
      final date = (tx['date'] as Timestamp).toDate();
      final day = DateTime(date.year, date.month, date.day);

      data.putIfAbsent(day, () => []);

      data[day]!.add({
        'amount': tx['amount'],
        'note': tx['note'],
        'by': tx['by'] ?? 'Аноним',
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  _buildCalendar(),

                  const SizedBox(height: 12),
                  Expanded(
                    child: _selectedDay == null
                        ? _emptyMessage("Выберите дату в календаре")
                        : _getEventsForDay(_selectedDay!).isEmpty
                        ? _emptyMessage("Нет взносов в этот день.\n“Поистине, лучшие дела — постоянные,\nпусть и малые.” (Хадис)")
                        : _buildTransactionList(),
                  ),
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

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
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
          markerDecoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
          todayDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.teal[700], shape: BoxShape.circle),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          formatButtonVisible: false,
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.teal),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.teal),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.nunito(color: Colors.grey[700]),
          weekendStyle: GoogleFonts.nunito(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _emptyMessage(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/kaaba.svg', height: 120),
            const SizedBox(height: 20),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final items = _getEventsForDay(_selectedDay!);

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final tx = items[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(Icons.attach_money_rounded, color: Colors.teal[800]),
            ),
            title: Text(
              "${tx['amount']} тг",
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "${tx['note']} — ${tx['by']}",
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[700]),
            ),
            trailing: Text(
              DateFormat('HH:mm').format(tx['date']),
              style: GoogleFonts.nunito(color: Colors.grey[500], fontSize: 13),
            ),
          ),
        );
      },
    );
  }
}