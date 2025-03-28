import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_hood/login-signup/login_screen.dart';
import 'package:safe_hood/widgets/popup.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phNumberController = TextEditingController();
  final TextEditingController emergencyPhController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController doorNumberController = TextEditingController();
  final TextEditingController flatcodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController numberOfPeopleController =
      TextEditingController();
  final TextEditingController flatNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController originalResidenceController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedRole = "User";
  final List<String> roles = ["User", "Admin", "Security"];

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        dobController.text = "${picked.toLocal()}".split('')[0];
        _calculateAge(picked);
      });
    }
  }

  void _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--; // If birthday hasn't occurred yet this year, subtract one year from the age
    }
    ageController.text = age.toString(); // Set the calculated age
  }

  void handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is invalid, return
    }

    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String occupation = occupationController.text.trim();
    String dob = dobController.text.trim();
    String age = ageController.text.trim();
    String doorNumber = doorNumberController.text.trim();
    String peopleCount = numberOfPeopleController.text.trim();
    String flatCode = flatcodeController.text.trim();
    String flatName = flatNameController.text.trim();
    String phone = phNumberController.text.trim();
    String emergencyPhone = emergencyPhController.text.trim();
    String emergencyContact = emergencyNameController.text.trim();
    String desc = descriptionController.text.trim();
    String origin = originalResidenceController.text.trim();
    String password = passwordController.text.trim();

    try {
      String hashedPass = BCrypt.hashpw(password, BCrypt.gensalt());

      await FirebaseFirestore.instance.collection("users").doc(email).set({
        "name": name,
        "email": email,
        "occupation": occupation,
        "dob": dob,
        "age": age,
        "doorNumber": doorNumber,
        "peopleCount": peopleCount,
        "flatCode": flatCode,
        "flatName": flatName,
        "phone": phone,
        "emergencyPhone": emergencyPhone,
        "emergencyContact": emergencyContact,
        "description": desc,
        "origin": origin,
        "password": hashedPass,
        "role": selectedRole,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Utils.showSuccess("Account created successfully", context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      Utils.showError("$e", context);
    }
  }

  Widget _buildDateOfBirthField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: dobController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'D.O.B',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {}
                return null;
              },
              readOnly: true,
            ),
          ),
          IconButton(
            onPressed: () {
              _selectDate(context);
            },
            icon: Icon(Icons.calendar_today, color: Color(0xFF770F7B)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator, {
    bool obscureText = false,
    String? hintext,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintext,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E3FF), // Lighter purple background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 50),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF2E3FF),
                  Colors.purple.shade100,
                ], // Lighter gradient
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.jpg', // Change this to your actual logo path
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "User Registration",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Merriweather",
                      color: Color.fromARGB(
                        255,
                        119,
                        15,
                        123,
                      ), // Matching color for the title text
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items:
                        roles.map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedRole = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // Input Fields
                  _buildTextField("Name*", nameController, (value) {
                    if (value == null || value.isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  }),
                  SizedBox(height: 10),
                  _buildTextField("Email ID *", emailController, (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  }),
                  SizedBox(height: 10),
                  _buildDateOfBirthField(),
                  SizedBox(height: 10),
                  _buildTextField("Age*", ageController, null, readOnly: true),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Phone Number* (10 digits)",
                    phNumberController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone Number is required";
                      }
                      if (value.length != 10 ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return "Phone number must be exactly 10 digits";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Emergency Name",
                    emergencyNameController,
                    null,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Emergency Phone Number",
                    emergencyPhController,
                    (value) {
                      if (value == phNumberController.text) {
                        return "Emergency phone number cannot be the same as phone number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  _buildTextField("Door Number", doorNumberController, null),
                  SizedBox(height: 10),
                  _buildTextField("Flat Code", flatcodeController, null),
                  SizedBox(height: 10),
                  _buildTextField("Password*", passwordController, (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  }, obscureText: true),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Confirm Password*",
                    confirmPasswordController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm Password is required";
                      }
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 10),

                  // Optional Fields
                  _buildTextField(
                    "Occupation (Optional)",
                    occupationController,
                    null,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Number of People Living (Optional)",
                    numberOfPeopleController,
                    null,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Flat Name (Optional)",
                    flatNameController,
                    null,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Description About Yourself (Optional)",
                    descriptionController,
                    null,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Original Place of Residence (Optional)",
                    originalResidenceController,
                    null,
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                        255,
                        119,
                        15,
                        123,
                      ), // Pink color for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an Account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'LogIn',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 140, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
