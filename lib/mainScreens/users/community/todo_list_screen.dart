import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPriority = 'Medium';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // ✅ Load userId from SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  // ✅ Add task to Firestore
  void _addTask() async {
    if (_userId == null) {
      print('No userId found! Cannot add task.');
      return;
    }
    if (_taskNameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    Map<String, dynamic> task = {
      'name': _taskNameController.text,
      'description': _taskDescController.text,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'time': _selectedTime!.format(context),
      'priority': _selectedPriority,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // ✅ Add task to 'tasks' collection for the logged-in user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .add(task);

    // Clear inputs after adding task
    _taskNameController.clear();
    _taskDescController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedPriority = 'Medium';
    });
  }

  // ✅ Select date
  void _selectDate() async {
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
  }

  // ✅ Select time
  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // ✅ Toggle task completion
  void _toggleCompletion(String taskId, bool isCompleted) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .update({'completed': !isCompleted});
  }

  // ✅ Delete task from Firestore
  void _deleteTask(String taskId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text(
          "To-Do List",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Task Input Form
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField("Task Name", _taskNameController),
                  _buildTextField("What to do", _taskDescController),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateTimeButton(
                        "Select Date",
                        _selectedDate == null
                            ? "Pick Date"
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        _selectDate,
                      ),
                      _buildDateTimeButton(
                        "Select Time",
                        _selectedTime == null
                            ? "Pick Time"
                            : _selectedTime!.format(context),
                        _selectTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items:
                        ["Low", "Medium", "High"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Add Task",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Task List Using StreamBuilder
            Expanded(
              child:
                  _userId == null
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder(
                        stream:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(_userId)
                                .collection('tasks')
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                        builder: (
                          context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          var tasks = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              var task = tasks[index];
                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    task['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${task['description']}\nDue: ${task['date']} at ${task['time']}\nPriority: ${task['priority']}",
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          task['completed']
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color:
                                              task['completed']
                                                  ? Colors.green
                                                  : null,
                                        ),
                                        onPressed:
                                            () => _toggleCompletion(
                                              task.id,
                                              task['completed'],
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteTask(task.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Reusable TextField Widget
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ✅ Reusable Button Widget for Date/Time Selection
  Widget _buildDateTimeButton(
    String label,
    String text,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
