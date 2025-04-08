import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

Future<DateTime?> showCustomCalendarSheet(BuildContext context) {
  DateTime selectedDay = DateTime.now().add(Duration(days: 30));

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Выбери дедлайн", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black,))
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar(
            locale: 'ru_RU',
            firstDay: DateTime.now(),
            lastDay: DateTime(2030),
            focusedDay: selectedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (day, _) => Navigator.pop(context, day),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.teal),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.teal),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.nunito(fontSize: 12),
              weekendStyle: GoogleFonts.nunito(fontSize: 12, color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}