import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final String description;
  final String theme;
  final String date;
  final String time;
  final String location;

  Event({
    required this.title,
    required this.description,
    required this.theme,
    required this.date,
    required this.time,
    required this.location,
  });
}

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  _AdminEventsScreenState createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final List<Event> events = [];

  void _addEvent() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Event"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text("Select Date: ${DateFormat('yMMMd').format(selectedDate)}"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: Text("Select Time: ${selectedTime.format(context)}"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  events.add(Event(
                    title: titleController.text,
                    description: descriptionController.text,
                    theme: categoryController.text,
                    date: DateFormat('yMMMd').format(selectedDate),
                    time: selectedTime.format(context),
                    location: locationController.text,
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        title: const Text("Admin: Manage Events"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: events.isEmpty
            ? const Center(child: Text("No events available. Add one!"))
            : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: const Icon(Icons.event, color: Colors.deepPurple, size: 40),
                      title: Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.description),
                          const SizedBox(height: 4),
                          Text("📍 ${event.location}"),
                          Text("📅 ${event.date} at ${event.time}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEvent(index),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _addEvent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
