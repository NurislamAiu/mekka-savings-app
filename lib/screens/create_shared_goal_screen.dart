import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateSharedGoalScreen extends StatefulWidget {
  const CreateSharedGoalScreen({super.key});

  @override
  State<CreateSharedGoalScreen> createState() => _CreateSharedGoalScreenState();
}

class _CreateSharedGoalScreenState extends State<CreateSharedGoalScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> allFriends = [];
  Set<String> selectedUIDs = {};

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final List<dynamic> friendUIDs = userDoc.data()?['friends'] ?? [];

    List<Map<String, dynamic>> loaded = [];

    for (String uid in friendUIDs) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        loaded.add({
          'uid': uid,
          'nickname': doc['nickname'] ?? '',
          'email': doc['email'] ?? '',
        });
      }
    }

    setState(() {
      allFriends = loaded;
    });
  }

  Future<void> _showCustomCalendar(BuildContext context) async {
    DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime selectedDay = DateTime.now().add(Duration(days: 30));
        return Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
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
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: Colors.black,))
                ],
              ),
              SizedBox(height: 12),
              TableCalendar(
                locale: 'ru_RU',
                firstDay: DateTime.now(),
                lastDay: DateTime(2030),
                focusedDay: selectedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                      color: Colors.teal, shape: BoxShape.circle),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  leftChevronIcon:
                  Icon(Icons.chevron_left, color: Colors.teal),
                  rightChevronIcon:
                  Icon(Icons.chevron_right, color: Colors.teal),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.nunito(fontSize: 12),
                  weekendStyle:
                  GoogleFonts.nunito(fontSize: 12, color: Colors.redAccent),
                ),
                onDaySelected: (day, _) {
                  selectedDay = day;
                  Navigator.pop(context, day);
                },
              ),
              SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _createGoal() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (title.isEmpty || amount <= 0 || _selectedDate == null) return;

    final currentUID = user!.uid;

    final creatorDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
    final nickname = creatorDoc['nickname'] ?? '';
    final email = creatorDoc['email'] ?? '';

    final members = [
      {
        'uid': currentUID,
        'nickname': nickname,
        'email': email,
        'role': 'admin',
        'confirmed': true,  
      },
      ...allFriends
          .where((f) => selectedUIDs.contains(f['uid']))
          .map((f) => {
        'uid': f['uid'],
        'nickname': f['nickname'],
        'email': f['email'],
        'role': 'member',
        'confirmed': false, 
      })
    ];

    final memberUIDs = members.map((m) => m['uid']).toList();

    await FirebaseFirestore.instance.collection('sharedGoals').add({
      'title': title,
      'targetAmount': amount,
      'deadline': Timestamp.fromDate(_selectedDate!),
      'savedAmount': 0,
      'createdBy': currentUID,
      'members': members,
      'memberUIDs': memberUIDs,
      'confirmed': false, 
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context, true);
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/kaaba.svg', height: 40),
                      SizedBox(width: 10),
                      Text(
                        "Общая цель с друзьями",
                        style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800]),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  
                  _cardInput("🎯 Название цели", _titleController),

                  SizedBox(height: 16),

                  
                  _cardInput("💰 Сумма цели (тг)", _amountController,
                      keyboardType: TextInputType.number),

                  SizedBox(height: 16),

                  
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.teal),
                      title: Text(
                        _selectedDate == null
                            ? "Выбрать дедлайн"
                            : DateFormat('dd MMMM yyyy', 'ru').format(_selectedDate!),
                        style: GoogleFonts.nunito(),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showCustomCalendar(context), 
                    ),
                  ),

                  SizedBox(height: 24),

                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("👥 Добавить друзей",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                  ),
                  ...allFriends.map((f) {
                    return CheckboxListTile(
                      activeColor: Colors.teal,
                      value: selectedUIDs.contains(f['uid']),
                      title: Text("@${f['nickname']}"),
                      subtitle: Text(f['email']),
                      onChanged: (val) {
                        setState(() {
                          if (val == true)
                            selectedUIDs.add(f['uid']);
                          else
                            selectedUIDs.remove(f['uid']);
                        });
                      },
                    );
                  }),

                  SizedBox(height: 24),

                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createGoal,
                      icon: Icon(Icons.check_circle_outline, color: Colors.white),
                      label: Text("Создать общую цель",
                          style: GoogleFonts.nunito(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  
                  Text(
                    '“Аллах помогает Своему рабу, пока тот помогает брату своему.” (Хадис)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardInput(String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
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