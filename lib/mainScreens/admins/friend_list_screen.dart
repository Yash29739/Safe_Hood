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

  // ✅ Factory to create Friend object from Firestore data
  factory Friend.fromMap(String id, Map<String, dynamic> data) {
    return Friend(
      id: id,
      name: data['name'] ?? 'Unknown',
      age: int.tryParse(data['age'].toString()) ?? 0,
      occupation: data['occupation'] ?? 'N/A',
      phoneNumber: data['phoneNumber'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
    );
  }
}

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen>
    with SingleTickerProviderStateMixin {
  String? _userId;
  String? _flatCode;
  List<String> _sentRequests = [];
  List<String> _friendsList = [];
  List<Map<String, dynamic>> _pendingRequests = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _tabController = TabController(length: 2, vsync: this);
  }

  // 🔥 Fetch User Details from SharedPreferences
  Future<void> _fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("userId");
      _flatCode = prefs.getString("flatCode");
    });

    if (_userId != null) {
      _fetchSentRequestsAndFriends();
    }
  }

  // 📚 Fetch Sent Requests and Friends List
  Future<void> _fetchSentRequestsAndFriends() async {
    if (_userId == null) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (userDoc.exists) {
      setState(() {
        _sentRequests = List<String>.from(userDoc['sentRequests'] ?? []);
        _friendsList = List<String>.from(userDoc['friendsList'] ?? []);
        _pendingRequests = List<Map<String, dynamic>>.from(
          userDoc['pendingRequests'] ?? [],
        );
      });
    }
  }

  // 📚 Fetch Friends List from Firestore
  Stream<QuerySnapshot> _getFriendsStream() {
    if (_userId == null || _flatCode == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .where(
          FieldPath.documentId,
          whereIn: _friendsList.isNotEmpty ? _friendsList : ['dummy'],
        )
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

  // 📥 Accept Friend Request
  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    String senderId = request['senderId'];
    String senderName = request['senderName'];

    // Add friend to both sender and receiver
    await FirebaseFirestore.instance.collection('users').doc(_userId).update({
      'friendsList': FieldValue.arrayUnion([senderId]),
      'pendingRequests': FieldValue.arrayRemove([request]),
    });

    await FirebaseFirestore.instance.collection('users').doc(senderId).update({
      'friendsList': FieldValue.arrayUnion([_userId]),
    });

    setState(() {
      _friendsList.add(senderId);
      _pendingRequests.remove(request);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$senderName is now your friend"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ❌ Decline Friend Request
  Future<void> _declineRequest(Map<String, dynamic> request) async {
    await FirebaseFirestore.instance.collection('users').doc(_userId).update({
      'pendingRequests': FieldValue.arrayRemove([request]),
    });

    setState(() {
      _pendingRequests.remove(request);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request declined"), backgroundColor: Colors.red),
    );
  }

  // 📄 Show Friend Requests
  Widget _buildRequestList() {
    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Text(
          "No pending requests",
          style: TextStyle(fontSize: 18, color: Colors.purple),
        ),
      );
    }

    return ListView.builder(
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> request = _pendingRequests[index];
        String senderName = request['senderName'] ?? 'Unknown';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                senderName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(senderName),
            subtitle: const Text('Sent you a friend request'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _acceptRequest(request),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _declineRequest(request),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📚 Build Friends List
  Widget _buildFriendsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFriendsStream(),
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
              "No friends yet",
              style: TextStyle(fontSize: 18, color: Colors.purple),
            ),
          );
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            Friend friend = Friend.fromMap(
              docs[index].id,
              docs[index].data() as Map<String, dynamic>,
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
                subtitle: Text('Age: ${friend.age} | ${friend.occupation}'),
              ),
            );
          },
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: "Friends"),
            Tab(icon: Icon(Icons.mail), text: "Requests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFriendsList(), _buildRequestList()],
      ),
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
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .where('flatCode', isEqualTo: _flatCode)
                      .where(FieldPath.documentId, isNotEqualTo: _userId)
                      .snapshots(),
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
}
