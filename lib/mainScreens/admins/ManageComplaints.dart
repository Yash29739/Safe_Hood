import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_hood/widgets/popup.dart'; // Reuse success/error popups

class ManageComplaintsScreen extends StatefulWidget {
  const ManageComplaintsScreen({super.key});

  @override
  State<ManageComplaintsScreen> createState() => _ManageComplaintsScreenState();
}

class _ManageComplaintsScreenState extends State<ManageComplaintsScreen> {
  String? _flatCode;
  String? _doorNumber;
  final List<String> _statusOptions = ["Pending", "Resolved", "Rejected"];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ✅ Fetch flatCode and doorNumber from SharedPreferences
  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");
      _doorNumber = prefs.getString("doorNumber");

      if (userId == null) {
        Utils.showError("Error: User ID not found.", context);
        return;
      }

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (!userDoc.exists) {
        Utils.showError("Error: User document not found.", context);
        return;
      }

      setState(() {
        _flatCode = userDoc["flatCode"];
      });
    } catch (e) {
      Utils.showError("Error fetching user data: $e", context);
    }
  }

  // ✅ Get complaints stream (filter by doorNumber if needed)
  Stream<QuerySnapshot> _getComplaintsStream() {
    if (_flatCode == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('flatcode')
        .doc(_flatCode)
        .collection('complaints')
        .where('doorNumber', isEqualTo: _doorNumber) // ✅ Filter by doorNumber
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ✅ Update complaint status
  Future<void> _updateComplaintStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('flatcode')
          .doc(_flatCode)
          .collection('complaints')
          .doc(docId)
          .update({"status": newStatus});

      Utils.showSuccess("Status updated successfully!", context);
    } catch (e) {
      Utils.showError("Error updating status: $e", context);
    }
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
      body:
          _flatCode == null
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
              : _buildComplaintsList(),
    );
  }

  // ✅ Build complaints list
  Widget _buildComplaintsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getComplaintsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purple),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No complaints found.", style: TextStyle(fontSize: 16)),
          );
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                docs[index].data() as Map<String, dynamic>;

            String docId = docs[index].id;
            String status = data["status"];

            return _buildComplaintCard(
              data["name"],
              data["subject"],
              data["description"],
              data["category"],
              data["timestamp"].toDate().toString().substring(0, 10),
              status,
              docId,
            );
          },
        );
      },
    );
  }

  // ✅ Build individual complaint card
  Widget _buildComplaintCard(
    String name,
    String subject,
    String description,
    String category,
    String date,
    String status,
    String docId,
  ) {
    Color statusColor = _getStatusColor(status);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Name:", name, Colors.purple.shade700),
            _buildInfoRow("Subject:", subject, Colors.purple),
            _buildInfoRow("Category:", category, Colors.orange),
            _buildInfoRow("Description:", description, Colors.black87),
            _buildInfoRow("Date:", date, Colors.black54),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: status,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.purple,
                    ),
                    items:
                        _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status,
                              style: TextStyle(color: _getStatusColor(status)),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != status) {
                        _updateComplaintStatus(docId, newValue);
                      }
                    },
                    underline: Container(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case "Resolved":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  // ✅ Build row for complaint details
  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: color),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Build App Header
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
