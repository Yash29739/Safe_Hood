import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuardPatrolPage extends StatefulWidget {
  @override
  _GuardPatrolPageState createState() => _GuardPatrolPageState();
}

class _GuardPatrolPageState extends State<GuardPatrolPage> {
  final List<Map<String, String>> patrolLogs = [
    {
      "location": "Main Gate",
      "notes": "Checked ID, all clear.",
      "time": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().subtract(Duration(hours: 1))),
    },
    {
      "location": "Parking Lot",
      "notes": "Suspicious vehicle, reported to supervisor.",
      "time": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().subtract(Duration(hours: 2))),
    },
    {
      "location": "Back Entrance",
      "notes": "Area secured, nothing unusual.",
      "time": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().subtract(Duration(hours: 3))),
    },
  ];

  final TextEditingController notesController = TextEditingController();
  String? selectedLocation;

  final List<String> locations = [
    "Main Gate",
    "Back Entrance",
    "Parking Lot",
    "Lobby",
    "Office Area",
    "CCTV Room",
  ];

  void _addPatrolLog() {
    if (selectedLocation != null) {
      setState(() {
        patrolLogs.insert(
          0,
          {
            "location": selectedLocation!,
            "notes": notesController.text.isEmpty ? "No additional notes" : notesController.text,
            "time": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          },
        );
      });
      selectedLocation = null;
      notesController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddPatrolDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text("Log Patrol Check-In", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedLocation,
                      hint: Text("Select Location", style: TextStyle(color: Colors.deepPurple)),
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                      items: locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: "Notes (Optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: _addPatrolLog,
                child: Text("Log", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guard Patrol Logs"),
        backgroundColor: const Color.fromARGB(255, 196, 62, 196),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, const Color.fromARGB(255, 193, 164, 199)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: patrolLogs.length,
          itemBuilder: (context, index) {
            final log = patrolLogs[index];
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 212, 131, 216),
                  child: Icon(Icons.security, color: Colors.white),
                ),
                title: Text(
                  "Location: ${log["location"]}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                subtitle: Text(
                  "Notes: ${log["notes"]}\nTime: ${log["time"]}",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPatrolDialog,
        backgroundColor: const Color.fromARGB(255, 175, 65, 176),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
