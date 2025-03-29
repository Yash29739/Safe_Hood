import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminMaintenance extends StatefulWidget {
  const AdminMaintenance({super.key});

  @override
  State<AdminMaintenance> createState() => _AdminMaintenanceState();
}

class _AdminMaintenanceState extends State<AdminMaintenance> {
  String? _flatCode;
  final List<String> _statusOptions = ["In Progress", "Completed", "Rejected"];

  @override
  void initState() {
    super.initState();
    _fetchFlatCode();
  }

  // ✅ Fetch flatCode using userId from SharedPreferences
  Future<void> _fetchFlatCode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        _showError("User ID not found in SharedPreferences.");
        return;
      }

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (!userDoc.exists) {
        _showError("User document not found.");
        return;
      }

      setState(() {
        _flatCode = userDoc["flatCode"];
      });
    } catch (e) {
      _showError("Error fetching flatCode: $e");
    }
  }

  // ✅ Fetch maintenance requests dynamically using flatCode
  Stream<QuerySnapshot> _getMaintenanceRequestsStream() {
    if (_flatCode == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('flatcode')
        .doc(_flatCode)
        .collection('maintenance_requests')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // ✅ Update status in Firestore
  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('flatcode')
          .doc(_flatCode)
          .collection('maintenance_requests')
          .doc(docId)
          .update({"status": newStatus});

      _showSuccess("Status updated successfully!");
    } catch (e) {
      _showError("Error updating status: $e");
    }
  }

  // ✅ Show success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // ✅ Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "Admin Maintenance",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          _flatCode == null
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
              : StreamBuilder<QuerySnapshot>(
                stream: _getMaintenanceRequestsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No maintenance requests found.",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  List<DocumentSnapshot> docs = snapshot.data!.docs;

                  // Separate requests into Pending and Resolved sections
                  List<DocumentSnapshot> pendingRequests = [];
                  List<DocumentSnapshot> resolvedRequests = [];

                  for (var doc in docs) {
                    String status = doc["status"];
                    if (status == "Completed") {
                      resolvedRequests.add(doc);
                    } else {
                      pendingRequests.add(doc);
                    }
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSectionTitle("🚧 Pending Issues"),
                        _buildRequestList(pendingRequests),
                        const SizedBox(height: 20),
                        _buildSectionTitle("✅ Resolved Issues"),
                        _buildRequestList(resolvedRequests),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  // ✅ Build section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  // ✅ Build request list (pending & resolved)
  Widget _buildRequestList(List<DocumentSnapshot> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("No requests found.", style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> data =
            requests[index].data() as Map<String, dynamic>;

        String docId = requests[index].id;
        String status = data["status"];
        String priority = data["priority"];

        return _buildRequestCard(data, docId, status, priority);
      },
    );
  }

  // ✅ Build individual request card with status dropdown
  Widget _buildRequestCard(
    Map<String, dynamic> data,
    String docId,
    String currentStatus,
    String priority,
  ) {
    Color statusColor = _getStatusColor(currentStatus);
    Color priorityColor = _getPriorityColor(priority);
    Color cardBgColor = _getCardBackgroundColor(priority);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor, // 🔥 Background color based on priority
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                "Category:",
                data["category"],
                Colors.purple.shade700,
              ),
              _buildInfoRow(
                "Description:",
                data["description"],
                Colors.black87,
              ),
              _buildInfoRow("Door Number:", data["doorNumber"], Colors.black87),
              _buildInfoRow(
                "Date:",
                data["date"].toString().substring(0, 10),
                Colors.black54,
              ),
              _buildInfoRow("Priority:", priority, priorityColor),
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: currentStatus,
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
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != currentStatus) {
                          _updateStatus(docId, newValue);
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
      ),
    );
  }

  // ✅ Get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  // ✅ Get color based on priority
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.amber;
      case "low":
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  // ✅ Get card background color based on priority
  Color _getCardBackgroundColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red.shade50;
      case "medium":
        return Colors.amber.shade50;
      case "low":
        return Colors.green.shade50;
      default:
        return Colors.grey.shade200;
    }
  }

  // ✅ Build row for request details
  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
}
