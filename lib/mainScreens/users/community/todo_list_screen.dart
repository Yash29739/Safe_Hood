import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _userId;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _initializeNotifications();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(settings);
    tz.initializeTimeZones();
  }

  Future<void> _scheduleNotification(String taskId, String taskName, DateTime scheduledTime) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      taskId.hashCode,
      "Task Reminder",
      "It's time for: $taskName",
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel',
          'Task Reminders',
          channelDescription: 'Reminds users of their tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _addTask() async {
    if (_userId == null || _taskNameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields!")));
      return;
    }

    DateTime scheduledTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute,
    );

    DocumentReference docRef = await FirebaseFirestore.instance.collection('users').doc(_userId).collection('tasks').add({
      'name': _taskNameController.text,
      'description': _taskDescController.text,
      'scheduledTime': scheduledTime.toIso8601String(),
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _scheduleNotification(docRef.id, _taskNameController.text, scheduledTime);
    _taskNameController.clear();
    _taskDescController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  Widget _buildTaskList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(_userId).collection('tasks').orderBy('scheduledTime').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No tasks available"));
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            DateTime taskTime = DateTime.parse(doc['scheduledTime']);
            String formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(taskTime);
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              color: Colors.purple.shade100,
              child: ListTile(
                title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${doc['description']}\nDue: $formattedTime"),
                trailing: Checkbox(
                  value: doc['completed'],
                  onChanged: (bool? value) {
                    FirebaseFirestore.instance.collection('users').doc(_userId).collection('tasks').doc(doc.id).update({'completed': value});
                  },
                ),
                onLongPress: () => FirebaseFirestore.instance.collection('users').doc(_userId).collection('tasks').doc(doc.id).delete(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To-Do List"), backgroundColor: Colors.purple, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _taskNameController, decoration: const InputDecoration(labelText: "Task Name")),
            TextField(controller: _taskDescController, decoration: const InputDecoration(labelText: "Task Description")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
                    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
                  },
                  child: Text(_selectedDate == null ? "Pick Date" : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (pickedTime != null) setState(() => _selectedTime = pickedTime);
                  },
                  child: Text(_selectedTime == null ? "Pick Time" : _selectedTime!.format(context)),
                ),
              ],
            ),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white), onPressed: _addTask, child: const Text("Add Task")),
            const SizedBox(height: 10),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }
}
