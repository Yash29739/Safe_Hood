import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_hood/widgets/popup.dart';

class AdminNoticeBoard extends StatefulWidget {
  const AdminNoticeBoard({super.key});

  @override
  _AdminNoticeBoardState createState() => _AdminNoticeBoardState();
}

class _AdminNoticeBoardState extends State<AdminNoticeBoard> {
  CollectionReference? noticesRef;
  String? flatCode;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadFlatCode();
  }

  Future<void> _loadFlatCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      flatCode = prefs.getString('flatCode');
      userId = prefs.getString('userId');
    });

    if (flatCode != null) {
      noticesRef = FirebaseFirestore.instance
          .collection('flatcode')
          .doc(flatCode)
          .collection('notices');
    }
  }

  void _addNotice() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Notice"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Title", titleController),
                const SizedBox(height: 8),
                _buildTextField("Description", descController),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      descController.text.isNotEmpty) {
                    try {
                      await noticesRef!.add({
                        "title": titleController.text,
                        "desc": descController.text,
                        "footer": "Posted by Admin • Just now",
                        "icon": "announcement",
                        "color": "purple",
                        "timestamp": FieldValue.serverTimestamp(),
                      });

                      Utils.showSuccess("Notice added successfully!", context);
                      Navigator.pop(context);
                    } catch (e) {
                      Utils.showError("Error adding notice: $e", context);
                    }
                  } else {
                    Utils.showError("Please fill out all fields.", context);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  void _deleteNotice(String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Notice"),
            content: const Text("Are you sure you want to delete this notice?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await noticesRef!.doc(docId).delete();
                    Utils.showSuccess("Notice deleted successfully!", context);
                    Navigator.pop(context);
                  } catch (e) {
                    Utils.showError("Error deleting notice: $e", context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
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
      backgroundColor: const Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFCC00FF),
        title: _buildHeader(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
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
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            List<DocumentSnapshot> notices = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notices.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    notices[index].data() as Map<String, dynamic>;

                return _buildNoticeCard(
                  data["title"],
                  data["desc"],
                  data["footer"] ?? "",
                  _getIconFromString(data["icon"] ?? "announcement"),
                  _getColorFromString(data["color"] ?? "purple"),
                  notices[index].id,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNotice,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoticeCard(
    String title,
    String desc,
    String footer,
    IconData icon,
    Color color,
    String docId,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              desc,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              footer,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteNotice(docId),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
