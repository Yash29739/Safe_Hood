import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitorEntryScreen extends StatefulWidget {
  const VisitorEntryScreen({super.key});

  @override
  _VisitorEntryScreenState createState() => _VisitorEntryScreenState();
}

class _VisitorEntryScreenState extends State<VisitorEntryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _flatCode;

  @override
  void initState() {
    super.initState();
    _fetchFlatCode();
  }

  Future<void> _fetchFlatCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _flatCode = prefs.getString("flatCode");
    });
  }

  Stream<QuerySnapshot> _getVisitorsLogStream() {
    if (_flatCode == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('flatcode')
        .doc(_flatCode)
        .collection('visitors_log')
        .orderBy('time', descending: true)
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
        title: Column(
          children: [
            _buildHeader(),
            const Text(
              "Visitor's Log",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {}); // Update UI on search change
              },
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
            Center(
              child: const Text(
                "Visitor Log",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 38, 38, 38),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            // 📚 Visitor Log List from Firestore
            Expanded(
              child:
                  _flatCode == null
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.purple),
                      )
                      : StreamBuilder<QuerySnapshot>(
                        stream: _getVisitorsLogStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _noVisitorLog();
                          }

                          List<DocumentSnapshot> docs = snapshot.data!.docs;
                          List<DocumentSnapshot> filteredDocs =
                              docs
                                  .where(
                                    (doc) => doc["name"].toLowerCase().contains(
                                      _searchController.text.toLowerCase(),
                                    ),
                                  )
                                  .toList();

                          return ListView.builder(
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> visitor =
                                  filteredDocs[index].data()
                                      as Map<String, dynamic>;
                              return _buildVisitorCard(visitor);
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 No Visitor Log UI
  Widget _noVisitorLog() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "No visitor logs available",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  // 📚 Visitor Card UI
  Widget _buildVisitorCard(Map<String, dynamic> visitor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(
            visitor["name"][0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(visitor["name"]),
        subtitle: Text(
          "Purpose: ${visitor["purpose"]}\nTime: ${visitor["time"]}",
        ),
      ),
    );
  }

  // 🎨 Build Header for AppBar
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
