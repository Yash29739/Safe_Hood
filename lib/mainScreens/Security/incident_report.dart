import 'dart:io';
import 'package:flutter/material.dart';

class IncidentReportsPage extends StatefulWidget {
  @override
  _IncidentReportsPageState createState() => _IncidentReportsPageState();
}

class _IncidentReportsPageState extends State<IncidentReportsPage> {
  final List<Map<String, dynamic>> incidentReports = [
    {
      "title": "Unauthorized Entry",
      "description":
          "A person was found entering a restricted area without permission.",
      "time": "2025-03-21 10:30",
      "image": null,
    },
    {
      "title": "Lost Item",
      "description": "A visitor reported losing a valuable item in the lobby.",
      "time": "2025-03-21 12:45",
      "image": null,
    },
    {
      "title": "Suspicious Activity",
      "description":
          "A group of individuals were seen loitering around the premises.",
      "time": "2025-03-21 14:10",
      "image": null,
    },
  ];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _selectedImage;

  void _addIncidentReport() {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      setState(() {
        incidentReports.add({
          "title": titleController.text,
          "description": descriptionController.text,
          "time": DateTime.now().toLocal().toString().substring(0, 16),
          "image": _selectedImage,
        });
      });
      titleController.clear();
      descriptionController.clear();
      _selectedImage = null;
      Navigator.pop(context);
    }
  }

  void _showAddIncidentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  "Report an Incident",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Incident Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          Image.file(
                            _selectedImage!,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Text(
                              "Remove Image",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: _addIncidentReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Submit"),
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
        title: Text("Incident Reports"),
        backgroundColor: const Color.fromARGB(255, 196, 62, 196),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade100,
              const Color.fromARGB(255, 193, 164, 199),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child:
                  incidentReports.isEmpty
                      ? Center(child: Text("No incident reports available."))
                      : ListView.builder(
                        itemCount: incidentReports.length,
                        itemBuilder: (context, index) {
                          final report = incidentReports[index];
                          return Card(
                            color: Colors.white,
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: ListTile(
                              leading:
                                  report["image"] != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          report["image"]!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Icon(
                                        Icons.report,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                              title: Text(
                                report["title"]!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Description: ${report["description"]}\nTime: ${report["time"]}",
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncidentDialog,
        backgroundColor: const Color.fromARGB(255, 196, 62, 196),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
