import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VisitorLogScreen extends StatefulWidget {
  const VisitorLogScreen({super.key});

  @override
  _VisitorLogScreenState createState() => _VisitorLogScreenState();
}

class _VisitorLogScreenState extends State<VisitorLogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _visitorList = [];
  List<DocumentSnapshot> _filteredVisitors = [];

  @override
  void initState() {
    super.initState();
    _fetchVisitors();
  }

  /// Fetch visitor logs in real-time from Firestore
  void _fetchVisitors() {
    _firestore.collection('visitors').snapshots().listen((snapshot) {
      setState(() {
        _visitorList = snapshot.docs;
        _filteredVisitors = _visitorList; // Default: Show all visitors
      });
    });
  }

  /// Search visitors by name
  void _searchVisitor(String query) {
    setState(() {
      _filteredVisitors = _visitorList
          .where((visitor) =>
              visitor["name"].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFCC00FF),
        title: Column(
          children: [
            _buildHeader(),
            const Text(
              "Visitor Log",
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _searchVisitor,
              decoration: InputDecoration(
                labelText: "Search Visitor",
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: const Text(
                "Visitor Log",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF262626)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredVisitors.isEmpty
                  ? _noVisitorLogWidget()
                  : ListView.builder(
                      itemCount: _filteredVisitors.length,
                      itemBuilder: (context, index) {
                        var visitor = _filteredVisitors[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(visitor["name"][0], style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(visitor["name"]),
                            subtitle: Text("Time: ${visitor["time"]}\nPhone: ${visitor["phone"]}"),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget to show when no visitors are found
  Widget _noVisitorLogWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: const Center(
        child: Text("No visitor logs available", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.purple)),
      ),
    );
  }

  /// Custom header
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
          style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Merriweather"),
        ),
      ],
    );
  }
}
