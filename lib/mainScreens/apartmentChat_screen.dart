import 'package:flutter/material.dart';

class ApartmentChatScreen extends StatefulWidget {
  const ApartmentChatScreen({super.key});

  @override
  State<ApartmentChatScreen> createState() => _ApartmentChatScreenState();
}

class _ApartmentChatScreenState extends State<ApartmentChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("hi chat"),);
  }
}