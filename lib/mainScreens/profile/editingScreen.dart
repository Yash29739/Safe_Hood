import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserScreen extends StatefulWidget {
  final String userEmail;

  const EditUserScreen({super.key, required this.userEmail});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _dobController;
  late TextEditingController _descriptionController;
  late TextEditingController _doorNumberController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _flatCodeController;
  late TextEditingController _flatNameController;
  late TextEditingController _occupationController;
  late TextEditingController _originController;
  late TextEditingController _peopleCountController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _dobController = TextEditingController();
    _descriptionController = TextEditingController();
    _doorNumberController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _flatCodeController = TextEditingController();
    _flatNameController = TextEditingController();
    _occupationController = TextEditingController();
    _originController = TextEditingController();
    _peopleCountController = TextEditingController();
    _phoneController = TextEditingController();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userEmail)
            .get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = data['name'] ?? '';
        _ageController.text = data['age'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _doorNumberController.text = data['doorNumber'] ?? '';
        _emergencyContactController.text = data['emergencyContact'] ?? '';
        _emergencyPhoneController.text = data['emergencyPhone'] ?? '';
        _flatCodeController.text = data['flatCode'] ?? '';
        _flatNameController.text = data['flatName'] ?? '';
        _occupationController.text = data['occupation'] ?? '';
        _originController.text = data['origin'] ?? '';
        _peopleCountController.text = data['peopleCount'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .update({
            'name': _nameController.text,
            'age': _ageController.text,
            'dob': _dobController.text,
            'description': _descriptionController.text,
            'doorNumber': _doorNumberController.text,
            'emergencyContact': _emergencyContactController.text,
            'emergencyPhone': _emergencyPhoneController.text,
            'flatCode': _flatCodeController.text,
            'flatName': _flatNameController.text,
            'occupation': _occupationController.text,
            'origin': _originController.text,
            'peopleCount': _peopleCountController.text,
            'phone': _phoneController.text,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data updated successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _descriptionController.dispose();
    _doorNumberController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _flatCodeController.dispose();
    _flatNameController.dispose();
    _occupationController.dispose();
    _originController.dispose();
    _peopleCountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Details'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Name', _nameController),
              _buildTextField('Age', _ageController, isNumber: true),
              _buildTextField('Date of Birth', _dobController),
              _buildTextField('Description', _descriptionController),
              _buildTextField('Door Number', _doorNumberController),
              _buildTextField('Emergency Contact', _emergencyContactController),
              _buildTextField('Emergency Phone', _emergencyPhoneController),
              _buildTextField('Flat Code', _flatCodeController),
              _buildTextField('Flat Name', _flatNameController),
              _buildTextField('Occupation', _occupationController),
              _buildTextField('Origin', _originController),
              _buildTextField('People Count', _peopleCountController),
              _buildTextField('Phone', _phoneController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
