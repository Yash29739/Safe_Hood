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

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _initializeNotifications();
  }

  // Load User ID from SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  // Initialize Notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(settings);
    tz.initializeTimeZones();
  }

  // Schedule Task Notification
  Future<void> _scheduleNotification(
    String taskId,
    String taskName,
    DateTime scheduledTime,
  ) async {
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

  // Add Task to Firestore
  void _addTask() async {
    if (_userId == null ||
        _taskNameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields!")),
      );
      return;
    }

    DateTime scheduledTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .add({
          'name': _taskNameController.text,
          'description': _taskDescController.text,
          'scheduledTime': scheduledTime.toIso8601String(),
          'completed': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

    _scheduleNotification(docRef.id, _taskNameController.text, scheduledTime);
    _clearForm();
  }

  // Clear Form After Adding Task
  void _clearForm() {
    _taskNameController.clear();
    _taskDescController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  // Delete Task
  void _deleteTask(String taskId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .delete()
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Task deleted successfully!"),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  // Build Task List
  Widget _buildTaskList() {
    if (_userId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .collection('tasks')
              .orderBy('scheduledTime')
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No tasks available",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            DateTime taskTime = DateTime.parse(doc['scheduledTime']);
            String formattedTime = DateFormat(
              'MMM dd, yyyy - hh:mm a',
            ).format(taskTime);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            doc['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Due: $formattedTime",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Checkbox(
                          value: doc['completed'],
                          onChanged: (bool? value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(_userId)
                                .collection('tasks')
                                .doc(doc.id)
                                .update({'completed': value});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(doc.id),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTaskForm(),
              const SizedBox(height: 20),
              _buildTaskList(),
            ],
          ),
        ),
      ),
    );
  }

  // Task Form
  Widget _buildTaskForm() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Task Name", _taskNameController),
            const SizedBox(height: 10),
            _buildTextField(
              "Task Description",
              _taskDescController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDatePickerButton(), _buildTimePickerButton()],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Add Task", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Date Picker Button
  Widget _buildDatePickerButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: Text(
        _selectedDate == null
            ? "Pick Date"
            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
      ),
    );
  }

  // Time Picker Button
  Widget _buildTimePickerButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            _selectedTime = pickedTime;
          });
        }
      },
      child: Text(
        _selectedTime == null ? "Pick Time" : _selectedTime!.format(context),
      ),
    );
  }

  // Text Field Widget
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        fillColor: Colors.grey[200],
        filled: true,
      ),
    );
  }
}
