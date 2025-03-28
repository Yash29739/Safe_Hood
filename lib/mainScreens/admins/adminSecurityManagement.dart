import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecurityManagementScreen extends StatelessWidget {
  const SecurityManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC00FF),
        title: const Text(
          "Security Management",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("security").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No security personnel found."));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var security = snapshot.data!.docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text(security["name"][0], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(security["name"] ?? "Unknown"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${security["status"] ?? "Unavailable"}"),
                      Text("Shift: ${security["shift"] ?? "Not Assigned"}"),
                      Text("Location: ${security["location"] ?? "Unknown"}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
