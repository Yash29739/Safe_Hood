import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Friend {
  final String id;
  final String name;
  final int age;
  final String occupation;
  final String phoneNumber;
  final String address;

  Friend({
    required this.id,
    required this.name,
    required this.age,
    required this.occupation,
    required this.phoneNumber,
    required this.address,
  });
}

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  String? _userId;
  String? _flatCode;
  List<String> _sentRequests = [];
  List<String> _friendsList = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // 🔥 Fetch User Details from SharedPreferences
  Future<void> _fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("userId");
      _flatCode = prefs.getString("flatCode");
    });

    debugPrint("User ID: $_userId, Flat Code: $_flatCode"); // Debugging line

    _fetchSentRequestsAndFriends();
  }

  // 📚 Fetch Sent Requests and Friends List
  Future<void> _fetchSentRequestsAndFriends() async {
    if (_userId == null) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    setState(() {
      _sentRequests = List<String>.from(userDoc['sentRequests'] ?? []);
      _friendsList = List<String>.from(userDoc['friendsList'] ?? []);
    });
  }

  // 📚 Fetch Apartment Members with Same FlatCode
  Stream<QuerySnapshot> _getMembersStream() {
    if (_flatCode == null || _userId == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .where('flatCode', isEqualTo: _flatCode) // Filter by flatCode
        .where(FieldPath.documentId, isNotEqualTo: _userId) // Exclude self
        .snapshots();
  }

  // 📨 Send Friend Request
  Future<void> _sendFriendRequest(
    String receiverId,
    String receiverName,
  ) async {
    if (_userId == null) return;

    // Update sender's sentRequests
    await FirebaseFirestore.instance.collection('users').doc(_userId).update({
      'sentRequests': FieldValue.arrayUnion([receiverId]),
    });

    // Add request to receiver's pendingRequests
    await FirebaseFirestore.instance.collection('users').doc(receiverId).update(
      {
        'pendingRequests': FieldValue.arrayUnion([
          {
            'senderId': _userId,
            'senderName': receiverName,
            'timestamp': Timestamp.now(),
          },
        ]),
      },
    );

    setState(() {
      _sentRequests.add(receiverId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Friend request sent to $receiverName"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ➕ Show Add Friend Dialog
  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Add New Friend",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMembersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No members available",
                      style: TextStyle(fontSize: 16, color: Colors.purple),
                    ),
                  );
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        docs[index].data() as Map<String, dynamic>;
                    String friendId = docs[index].id;
                    String friendName = data['name'] ?? 'Unknown';

                    bool isRequestSent = _sentRequests.contains(friendId);
                    bool isAlreadyFriend = _friendsList.contains(friendId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          friendName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(friendName),
                      subtitle: Text(data['occupation'] ?? 'N/A'),
                      trailing:
                          isAlreadyFriend
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : isRequestSent
                              ? const Icon(
                                Icons.hourglass_top,
                                color: Colors.orange,
                              )
                              : IconButton(
                                icon: const Icon(
                                  Icons.person_add,
                                  color: Colors.purple,
                                ),
                                onPressed: () {
                                  _sendFriendRequest(friendId, friendName);
                                  Navigator.pop(context);
                                },
                              ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 📄 Show Friend Details Dialog
  void _showFriendDetails(Friend friend) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(friend.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Age: ${friend.age}'),
              Text('Occupation: ${friend.occupation}'),
              Text('Phone: ${friend.phoneNumber}'),
              Text('Address: ${friend.address}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getMembersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No friends available",
                  style: TextStyle(fontSize: 16, color: Colors.purple),
                ),
              );
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    docs[index].data() as Map<String, dynamic>;
                Friend friend = Friend(
                  id: docs[index].id,
                  name: data['name'] ?? 'Unknown',
                  age: data['age'] ?? 0,
                  occupation: data['occupation'] ?? 'Unknown',
                  phoneNumber: data['phoneNumber'] ?? 'N/A',
                  address: data['address'] ?? 'N/A',
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        friend.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(friend.name),
                    subtitle: Text(
                      'Age: ${friend.age} | Occupation: ${friend.occupation}',
                    ),
                    onTap: () {
                      _showFriendDetails(friend);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      // ➕ Floating Action Button (FAB) for adding new friends
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
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
