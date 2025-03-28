import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApartmentChatScreen extends StatefulWidget {
  const ApartmentChatScreen({super.key});

  @override
  State<ApartmentChatScreen> createState() => _ApartmentChatScreenState();
}

class _ApartmentChatScreenState extends State<ApartmentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  late CollectionReference chatRef;
  String? flatCode;
  String? userName;
  late ScrollController _scrollController;
  bool _showScrollButton = false;

  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_checkIfScrolled);
    _loadFlatCode();
  }

  void _checkIfScrolled() {
    if (_scrollController.offset <=
        _scrollController.position.maxScrollExtent) {
      if (!_showScrollButton) {
        setState(() {
          _showScrollButton = true;
        });
      }
    } else {
      if (_showScrollButton) {
        setState(() {
          _showScrollButton = false;
        });
      }
    }
  }

  void scrollToBottom({int duration = 300}) {
    if (_scrollController.hasClients) {
      // double currentOffset = _scrollController.offset;
      // double maxScrollExtent = _scrollController.position.maxScrollExtent;

      // if ((maxScrollExtent - currentOffset).abs() > 20) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      // }
    }
  }

  Future<void> _loadFlatCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      flatCode = prefs.getString("flatCode");
      userName = prefs.getString("userName");
    });
    chatRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(flatCode)
        .collection("messages");

    Future.delayed(Duration(milliseconds: 500), () {
      scrollToBottom();
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && flatCode != null) {
      await chatRef.add({
        "user": userName,
        "message": _messageController.text,
        "time": FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      Future.delayed(Duration(milliseconds: 300), () {
        scrollToBottom(duration: 700);
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Now";
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      flatCode == null
                          ? null // Return null if flatCode is not loaded yet
                          : FirebaseFirestore.instance
                              .collection("chats")
                              .doc(flatCode)
                              .collection("messages")
                              .orderBy("time", descending: false)
                              .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No messages yet. Start the conversation!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    var docs = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var message =
                            docs[index].data() as Map<String, dynamic>;
                        bool isUser = message["user"] == userName;

                        if (index == docs.length - 1) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            scrollToBottom(duration: 500);
                          });
                        }

                        return Align(
                          alignment:
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                                isUser
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                            children: [
                              Text(
                                message["user"] ?? "Unknown",
                                style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color.fromARGB(181, 90, 90, 90),
                                ),
                              ),

                              Container(
                                margin:
                                    isUser
                                        ? EdgeInsets.only(bottom: 15, right: 80)
                                        : const EdgeInsets.only(
                                          bottom: 15,
                                          left: 80,
                                        ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      isUser
                                          ? Colors.purple[100]
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Text(
                                      message["message"] ?? "",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatTimestamp(message["time"]),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.purple),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Attach featurecoming soon!")),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message... ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: _showScrollButton,
          child: Positioned(
            bottom: 80,
            right: 20,

            child: AnimatedOpacity(
              opacity: 0.7,
              duration: Duration(milliseconds: 300),
              child: FloatingActionButton.small(
                onPressed: () {
                  scrollToBottom(duration: 500);
                },
                backgroundColor: Colors.purple,
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
