import 'package:flutter/material.dart';


class AdminNoticeBoard extends StatefulWidget {
  @override
  _AdminNoticeBoardState createState() => _AdminNoticeBoardState();
}

class _AdminNoticeBoardState extends State<AdminNoticeBoard> {
  List<Map<String, dynamic>> notices = [
    {"title": "Emergency Notice", "desc": "Building maintenance: Water shutdown tomorrow 8AM-2PM", "footer": "Posted by Management • 2 hours ago", "icon": Icons.warning, "color": Colors.red},
    {"title": "Weekend BBQ", "desc": "Join us for our monthly community BBQ at the courtyard!", "footer": "Saturday, July 15 • 4:00 PM", "icon": Icons.event, "color": Colors.blue},
    {"title": "Yoga in the Park", "desc": "Free yoga session for all community members", "footer": "Sunday, July 16 • 6:00 AM", "icon": Icons.spa, "color": Colors.green},
    {"title": "Lost & Found", "desc": "Found: House keys with blue keychain near Building C", "footer": "Posted by John Smith • 3 hours ago", "icon": Icons.search, "color": Colors.black54},
    {"title": "Parking Notice", "desc": "Please remember to display your parking permit at all times", "footer": "Posted by Security Team • 5 hours ago", "icon": Icons.local_parking, "color": Colors.black54},
    {"title": "For Sale", "desc": "Gently used patio furniture set - \$200", "footer": "Posted by Maria Garcia • 1 day ago", "icon": Icons.sell, "color": Colors.orange},
  ];

  void _addNotice() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Notice"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                setState(() {
                  notices.add({
                    "title": titleController.text,
                    "desc": descController.text,
                    "footer": "Posted by Admin • Just now",
                    "icon": Icons.announcement,
                    "color": Colors.purple,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _deleteNotice(int index) {
    setState(() {
      notices.removeAt(index);
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
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: notices.length,
          itemBuilder: (context, index) {
            return _buildNoticeCard(
              notices[index]["title"],
              notices[index]["desc"],
              notices[index]["footer"],
              notices[index]["icon"],
              notices[index]["color"],
              index,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNotice,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoticeCard(String title, String desc, String footer, IconData icon, Color color, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            Text(footer, style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteNotice(index),
        ),
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
        SizedBox(width: 10),
        Text(
          "ADMIN BOARD",
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
      ],
    );
  }
}
