import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class NoticeBoardScreen extends StatefulWidget {
  @override
  _NoticeBoardScreenState createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _postNotice() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('notices').add({
        'title': 'Admin Notice',
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('notices')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var notices = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    return _buildNoticeCard(
                      notices[index]['title'],
                      notices[index]['message'],
                      notices[index]['timestamp']?.toDate().toString() ?? '',
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Enter notice"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _postNotice,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(String title, String desc, String footer) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.announcement, color: Colors.red),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            Text(footer, style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
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
