import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  String selectedCategory = "Noise";
  final List<String> categories = [
    "Noise",
    "Maintenance",
    "Security",
    "Cleanliness",
    "Parking",
    "Other",
  ];

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? flatCode; // Stores flat code from Firestore
  String? doorNumber; // Stores door number from Firestore
  String? userName; // Stores user name from Firestore
  String? editingDocId; // Stores the ID of the complaint being edited

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Load user details when screen loads
  }

  // ✅ Load User Data (flatCode, doorNumber, userName) from Firestore
  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

      if (userDoc.exists) {
        setState(() {
          flatCode = userDoc["flatCode"];
          doorNumber = userDoc["doorNumber"];
          userName = userDoc["name"];
        });
      } else {
        _showError("User data not found!");
      }
    }
  }

  // ✅ Submit or Update Complaint to Firestore using unique docId
  Future<void> _submitComplaint() async {
    if (_subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        flatCode == null ||
        doorNumber == null ||
        userName == null) {
      _showError("Please fill all fields before submitting.");
      return;
    }

    try {
      // 🔄 If editing, update the existing document
      if (editingDocId != null) {
        await FirebaseFirestore.instance
            .collection('flatcode')
            .doc(flatCode)
            .collection('complaints')
            .doc(editingDocId)
            .update({
              'subject': _subjectController.text,
              'description': _descriptionController.text,
              'category': selectedCategory,
              'doorNumber': doorNumber,
              'name': userName,
              'status': 'Pending',
              'timestamp': FieldValue.serverTimestamp(),
            });

        _showSuccess("Complaint updated successfully!");
      } else {
        // ✅ Generate unique docId if new complaint
        String complaintId =
            FirebaseFirestore.instance
                .collection('flatcode')
                .doc(flatCode)
                .collection('complaints')
                .doc()
                .id;

        await FirebaseFirestore.instance
            .collection('flatcode')
            .doc(flatCode)
            .collection('complaints')
            .doc(complaintId) // ✅ Use unique complaintId as document ID
            .set({
              'subject': _subjectController.text,
              'description': _descriptionController.text,
              'category': selectedCategory,
              'doorNumber': doorNumber,
              'name': userName,
              'status': 'Pending',
              'timestamp': FieldValue.serverTimestamp(),
            });

        _showSuccess("Complaint submitted successfully!");
      }

      _clearForm(); // Clear form after submission
    } catch (e) {
      _showError("Failed to submit complaint. Please try again.");
    }
  }

  // ✅ Clear form after submission
  void _clearForm() {
    _subjectController.clear();
    _descriptionController.clear();
    setState(() {
      selectedCategory = "Noise";
      editingDocId = null;
    });
  }

  // ✅ Delete Complaint using unique complaintId
  Future<void> _deleteComplaint(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('flatcode')
          .doc(flatCode)
          .collection('complaints')
          .doc(docId)
          .delete();

      _showSuccess("Complaint deleted successfully!");
    } catch (e) {
      _showError("Failed to delete complaint.");
    }
  }

  // ✅ Load complaint data for editing
  void _editComplaint(String docId, Map<String, dynamic> data) {
    setState(() {
      _subjectController.text = data['subject'];
      _descriptionController.text = data['description'];
      selectedCategory = data['category'];
      editingDocId = docId; // Store complaint ID to update later
    });
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
      backgroundColor: const Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFCC00FF),
        title: _buildHeader(),
      ),
      body:
          flatCode == null || doorNumber == null
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildComplaintForm(), // Complaint Form
                    const SizedBox(height: 20),
                    _buildComplaintList(), // Display Complaints List
                  ],
                ),
              ),
    );
  }

  // ✅ Complaint Form Widget
  Widget _buildComplaintForm() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Subject", _subjectController),
            const SizedBox(height: 10),
            _buildTextField("Description", _descriptionController, maxLines: 4),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children:
                  categories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      selectedColor: Colors.purple,
                      labelStyle: TextStyle(
                        color:
                            selectedCategory == category
                                ? Colors.white
                                : Colors.black,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  editingDocId == null ? "Submit" : "Update",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Display Complaints List
  Widget _buildComplaintList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('flatcode')
              .doc(flatCode)
              .collection('complaints')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No complaints available.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        var docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String docId = docs[index].id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 5,
              child: ListTile(
                title: Text(
                  data['subject'] ?? "No Subject",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Category: ${data['category']}"),
                    Text("Door No: ${data['doorNumber']}"),
                    Text("Status: ${data['status']}"),
                    Text("Description: ${data['description']}"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editComplaint(docId, data);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteComplaint(docId);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Text Field Widget
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        fillColor: Colors.grey[200],
        filled: true,
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
}
