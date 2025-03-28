import 'package:flutter/material.dart';

class CommunityRulesApp extends StatelessWidget {
  const CommunityRulesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const CommunityRulesPage(),
    );
  }
}

class CommunityRulesPage extends StatelessWidget {
  const CommunityRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E3FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Color(0xFFCC00FF),
        title: _buildHeader(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRuleCard(Icons.volume_up, 'Quiet Hours',
                '10:00 PM - 7:00 AM daily\nPlease be mindful of noise levels during these hours.'),
            _buildRuleCard(Icons.local_parking, 'Parking Regulations',
                '- Residents must display valid parking permits\n- Guest parking limited to designated areas\n- No vehicle maintenance in parking areas\n- Maximum 2 vehicles per unit'),
            _buildRuleCard(Icons.pets, 'Pet Policy',
                '- Maximum 2 pets per unit\n- Dogs must be leashed\n- Clean up after pets\n- Weight limit: 50 lbs per pet\n- Breed restrictions apply'),
            _buildRuleCard(Icons.pool, 'Pool & Amenities',
                '- Pool hours: 6:00 AM - 10:00 PM\n- No glass containers\n- Children under 14 must be supervised\n- No diving\n- Pool fobs required'),
            _buildRuleCard(Icons.dangerous, 'Prohibited Items',
                '- Grills on balconies\n- Satellite dishes\n- Window AC units\n- Unauthorized security cameras\n- Illegal substances', Colors.redAccent),
            _buildRuleCard(Icons.warning, 'Violations',
                '- First violation: Written warning\n- Second violation: \$50 fine\n- Third violation: \$100 fine\n- Continued violations may result in lease termination', Colors.amber),
            _buildRuleCard(Icons.help, 'Questions?',
                'Contact the management office:\nPhone: (555) 123-4567', Colors.blueAccent),
          ],
        ),
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

  Widget _buildRuleCard(IconData icon, String title, String content, [Color? color]) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? Colors.deepPurple),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
