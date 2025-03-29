import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEventRequestsScreen extends StatelessWidget {
  void _approveEvent(DocumentSnapshot event) async {
    await FirebaseFirestore.instance.collection("upcoming_events").add({
      "title": event["title"],
      "description": event["description"],
      "category": event["category"],
      "date": event["date"],
      "location": event["location"],
      "added_by": "admin123", // Replace with actual admin ID
      "timestamp": FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection("event_requests").doc(event.id).update({"status": "approved"});
  }

  void _rejectEvent(String eventId) async {
    await FirebaseFirestore.instance.collection("event_requests").doc(eventId).update({"status": "rejected"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Event Requests")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("event_requests").where("status", isEqualTo: "pending").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) return Center(child: Text("No pending requests"));

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc["title"]),
                  subtitle: Text(doc["description"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () => _approveEvent(doc)),
                      IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => _rejectEvent(doc.id)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
