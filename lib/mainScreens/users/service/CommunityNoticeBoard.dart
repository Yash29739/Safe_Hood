import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityNoticeBoard extends StatefulWidget {
  const CommunityNoticeBoard({super.key});

  @override
  _CommunityNoticeBoardState createState() => _CommunityNoticeBoardState();
}

class _CommunityNoticeBoardState extends State<CommunityNoticeBoard> {
  CollectionReference? noticesRef;
  String? flatCode;

  @override
  void initState() {
    super.initState();
    _loadFlatCode();
  }

  Future<void> _loadFlatCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      flatCode = prefs.getString('flatCode');
    });

    if (flatCode != null) {
      noticesRef = FirebaseFirestore.instance
          .collection('flatcode')
          .doc(flatCode)
          .collection('notices');
    }
  }

  Stream<QuerySnapshot> _getNoticesStream() {
    if (noticesRef == null) {
      return const Stream.empty();
    }
    return noticesRef!.orderBy('timestamp', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: _buildCustomAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getNoticesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notices available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          List<DocumentSnapshot> notices = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              var notice = notices[index];
              return _buildNoticeCard(notice);
            },
          );
        },
      ),
    );
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.purple,
      elevation: 4,
      toolbarHeight: 100,
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                "assets/logo.jpg",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "SAFE HOOD",
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: "Merriweather",
            ),
          ),
        ],
      ),
      // Removed leading and actions to hide arrow and notifications
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildNoticeCard(DocumentSnapshot doc) {
    String title = doc['title'] ?? "No Title";
    String desc = doc['desc'] ?? "No description available.";
    String footer = doc['footer'] ?? "";
    String icon = doc['icon'] ?? "announcement";
    String color = doc['color'] ?? "purple";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          _getIconFromString(icon),
          color: _getColorFromString(color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getColorFromString(color),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              footer,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case "warning":
        return Icons.warning;
      case "event":
        return Icons.event;
      case "spa":
        return Icons.spa;
      case "search":
        return Icons.search;
      case "local_parking":
        return Icons.local_parking;
      case "sell":
        return Icons.sell;
      default:
        return Icons.announcement;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "orange":
        return Colors.orange;
      case "black54":
        return Colors.black54;
      case "purple":
        return Colors.purple;
      default:
        return Colors.purple;
    }
  }
}
