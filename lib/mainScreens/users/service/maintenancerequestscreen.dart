import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_hood/widgets/popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceRequestsScreen extends StatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  State<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState extends State<MaintenanceRequestsScreen> {
  final TextEditingController _issueController = TextEditingController();
  String _selectedPriority = "High";
  String _selectedCategory = "Plumbing";
  String? _flatCode;

  final List<String> _priorities = ["High", "Medium", "Low"];
  final List<String> _categories = [
    "Plumbing",
    "Electrical",
    "AC Maintenance",
    "General",
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        Utils.showError(
          "Error: User ID not found in SharedPreferences.",
          context,
        );
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

      // Get flatCode and store it in state
      setState(() {
        _flatCode = userDoc["flatCode"];
      });
    } catch (e) {
      Utils.showError("Error fetching user data: $e", context);
    }
  }

  Future<void> _submitMaintenanceRequest() async {
    if (_issueController.text.isEmpty) {
      Utils.showError("Please enter a valid issue description.", context);
      return;
    }

    if (_flatCode == null) {
      Utils.showError("Error: Flat code not found.", context);
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? doorNumber = prefs.getString("doorNumber");

      // ✅ Add maintenance request to Firestore
      await FirebaseFirestore.instance
          .collection('flatcode')
          .doc(_flatCode)
          .collection('maintenance_requests')
          .add({
            "doorNumber": doorNumber,
            "description": _issueController.text,
            "priority": _selectedPriority,
            "category": _selectedCategory,
            "date": DateTime.now().toIso8601String(),
            "status": "In Progress",
          });

      Utils.showSuccess("Request submitted successfully!", context);

      // Reset form after submission
      _issueController.clear();
      setState(() {
        _selectedPriority = "High";
        _selectedCategory = "Plumbing";
      });
    } catch (e) {
      Utils.showError("Error submitting request: $e", context);
    }
  }

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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNewRequestCard(),
                    const SizedBox(height: 16),
                    _buildSectionTitle("Active & Completed Requests"),
                    _buildRequestsList(),
                  ],
                ),
              ),
    );
  }

  Widget _buildRequestsList() {
    return StreamBuilder<QuerySnapshot>(
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

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                docs[index].data() as Map<String, dynamic>;
            return _buildRequestCard(
              data["category"],
              data["description"],
              "Submitted: ${data["date"].substring(0, 10)}",
              "${data["priority"]} Priority",
              data["status"],
              data["priority"] == "High"
                  ? const Color.fromARGB(59, 255, 17, 0)
                  : data["priority"] == "Low"
                  ? const Color.fromARGB(69, 0, 255, 8)
                  : const Color.fromARGB(75, 255, 235, 59),
              data["priority"] == "High"
                  ? const Color.fromARGB(255, 255, 17, 0)
                  : data["priority"] == "Low"
                  ? const Color.fromARGB(255, 51, 194, 56)
                  : Colors.yellow,
            );
          },
        );
      },
    );
  }

  Widget _buildNewRequestCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("New Request"),
            TextField(
              controller: _issueController,
              decoration: InputDecoration(
                hintText: "Issue Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(_priorities, _selectedPriority, (
                    value,
                  ) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(_categories, _selectedCategory, (
                    value,
                  ) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitMaintenanceRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Submit Request",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
        onChanged: onChanged,
        items:
            items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRequestCard(
    String title,
    String desc,
    String date,
    String priority,
    String status,
    Color bgColor,
    Color labelColor,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(title, priority, labelColor),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (status.isNotEmpty)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Status: $status",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        status == "Completed" || status == "Resolved"
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title, String priority, Color labelColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (priority.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priority,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
      ],
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
