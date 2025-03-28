import 'package:flutter/material.dart';

class ManageComplaintsScreen extends StatefulWidget {
  const ManageComplaintsScreen({super.key});

  @override
  State<ManageComplaintsScreen> createState() => _ManageComplaintsScreenState();
}

class _ManageComplaintsScreenState extends State<ManageComplaintsScreen> {
  List<Map<String, dynamic>> complaints = [
    {'id': 1, 'title': 'Water leakage', 'status': 'Pending'},
    {'id': 2, 'title': 'Noise disturbance', 'status': 'Resolved'},
    {'id': 3, 'title': 'Broken streetlight', 'status': 'Pending'},
  ];

  @override
  void initState() {
    super.initState();
    // Simulate a notification when a new complaint is added
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New complaints received"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Color(0xFFCC00FF),
        title: _buildHeader(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(complaints[index]['title']),
              subtitle: Text("Status: ${complaints[index]['status']}"),
              trailing: complaints[index]['status'] == 'Resolved'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.warning, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
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
        // Add your logo here
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
        SizedBox(height: 30),
      ],
    );
  }