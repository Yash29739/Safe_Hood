import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final String category;
  final String date;
  final String location;

  Event({
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.location,
  });
}

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  _UpcomingEventsScreenState createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  final List<Event> events = [];

  void _addEvent() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
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
                child: Text(
                  "Select Date: ${selectedDate.toLocal()}".split(' ')[0],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  events.add(
                    Event(
                      title: titleController.text,
                      description: descriptionController.text,
                      category: categoryController.text,
                      date: "${selectedDate.toLocal()}".split(' ')[0],
                      location: locationController.text,
                    ),
                  );
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
      backgroundColor: const Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFCC00FF),
        title: Column(
          children: [
            _buildHeader(),
            const Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            events.isEmpty
                ? const Center(child: Text("No events available. Add one!"))
                : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text(
                          "${event.description}\nLocation: ${event.location}",
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(event.date),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvent(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _addEvent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset("assets/logo.jpg", height: 60),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "SAFE HOOD",
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
      ],
    );
  }
}
