import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitorEntryScreen extends StatefulWidget {
  const VisitorEntryScreen({super.key});

  @override
  State<VisitorEntryScreen> createState() => _VisitorEntryScreenState();
}

class _VisitorEntryScreenState extends State<VisitorEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isAuthenticated = false;
  final String _watchmanPin = "1234";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _showPinDialog);
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text("Enter Watchman PIN"),
            content: TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "PIN"),
            ),
            actions: [
              TextButton(onPressed: _verifyPin, child: const Text("Submit")),
            ],
          ),
    );
  }

  // ✅ Verify PIN
  void _verifyPin() {
    if (_pinController.text == _watchmanPin) {
      setState(() {
        _isAuthenticated = true;
      });
      Navigator.pop(context); // ✅ Close PIN dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN! Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
    _pinController.clear(); // ✅ Clear PIN after verification
  }

  // ✅ Add Visitor to Firestore Inside Correct Path
  Future<void> _addVisitor() async {
    if (_isAuthenticated &&
        _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _roomController.text.isNotEmpty &&
        _purposeController.text.isNotEmpty) {
      try {
        // ✅ Get flatCode from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? flatCode = prefs.getString("flatCode");

        if (flatCode == null || flatCode.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: Flat code not found!"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // ✅ Store visitor data under correct path: /flatcode/{flatCode}/visitors/
        await _firestore
            .collection('flatcode') // ✅ Main collection
            .doc(flatCode) // ✅ Correct flatCode document
            .collection('visitors') // ✅ Store inside visitors collection
            .add({
              "name": _nameController.text,
              "phone": _phoneController.text,
              "room": _roomController.text,
              "purpose": _purposeController.text,
              "time": Timestamp.now(),
            });

        _clearFields(); // ✅ Clear input fields after adding visitor
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Visitor added successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding visitor: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Clear Input Fields
  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _roomController.clear();
    _purposeController.clear();
  }

  // ✅ Fetch Visitor Logs from Firestore Inside Correct Path
  Stream<QuerySnapshot> _fetchVisitorLogs() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? flatCode = prefs.getString("flatCode");

    if (flatCode == null || flatCode.isEmpty) {
      yield* const Stream.empty();
    } else {
      yield* _firestore
          .collection('flatcode')
          .doc(flatCode) // ✅ Correct flatCode document
          .collection('visitors') // ✅ Fetch visitors from correct path
          .orderBy('time', descending: true)
          .snapshots();
    }
  }

  // ✅ Build Visitor List with Search Feature
  Widget _buildVisitorList(QuerySnapshot snapshot) {
    var visitors = snapshot.docs;
    String query = _searchController.text.toLowerCase();

    // ✅ Filter based on search query
    List filteredVisitors =
        visitors.where((visitor) {
          var data = visitor.data() as Map<String, dynamic>;
          return data['name'].toString().toLowerCase().contains(query) ||
              data['phone'].toString().contains(query) ||
              data['room'].toString().contains(query);
        }).toList();

    if (filteredVisitors.isEmpty) {
      return const Center(
        child: Text(
          "No matching visitor logs found!",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.purple,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredVisitors.length,
      itemBuilder: (context, index) {
        var visitor = filteredVisitors[index].data() as Map<String, dynamic>;
        DateTime visitTime = DateTime.fromMillisecondsSinceEpoch(
          visitor['time'].millisecondsSinceEpoch,
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                visitor['name'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(visitor['name']),
            subtitle: Text(
              "Phone: ${visitor['phone']}\n"
              "Room: ${visitor['room']}\n"
              "Purpose: ${visitor['purpose']}\n"
              "Time: ${visitTime.toLocal()}",
            ),
          ),
        );
      },
    );
  }

  // ✅ Build Text Field Widget
  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType type = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
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
        title: const Text(
          "Visitor Log",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isAuthenticated) ...[
              _buildTextField(_nameController, "Visitor Name"),
              _buildTextField(
                _phoneController,
                "Phone Number",
                TextInputType.phone,
              ),
              _buildTextField(_roomController, "Room Number"),
              _buildTextField(_purposeController, "Purpose of Visit"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addVisitor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Add Visitor",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // ✅ Search Field
            TextField(
              controller: _searchController,
              onChanged:
                  (value) => setState(() {}), // ✅ Update search dynamically
              decoration: InputDecoration(
                labelText: "Search Visitor",
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // ✅ Visitor List with Real-time Updates
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchVisitorLogs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No visitor logs available!",
                        style: TextStyle(fontSize: 16, color: Colors.purple),
                      ),
                    );
                  }
                  return _buildVisitorList(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
