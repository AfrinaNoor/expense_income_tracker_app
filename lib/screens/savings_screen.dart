import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> savingsCategories = [
    {'name': 'Travel', 'icon': Icons.flight_takeoff, 'color': Colors.blue},
    {'name': 'Treatment', 'icon': Icons.local_hospital, 'color': Colors.red},
    {'name': 'Wedding', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'Emergency', 'icon': Icons.warning, 'color': Colors.orange},
    {'name': 'Kids', 'icon': Icons.child_care, 'color': Colors.green},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.purple},
    {'name': 'Retirement', 'icon': Icons.beach_access, 'color': Colors.teal},
    {'name': 'Hobbies', 'icon': Icons.brush, 'color': Colors.amber},
    {'name': 'Home Renovation', 'icon': Icons.home, 'color': Colors.brown},
    {'name': 'Fitness', 'icon': Icons.fitness_center, 'color': Colors.deepPurple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Categories'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent.shade400, Colors.purpleAccent.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: savingsCategories.length,
            itemBuilder: (context, index) {
              final category = savingsCategories[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                color: category['color'].withOpacity(0.2),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavingsDetailScreen(
                          categoryName: category['name'],
                          icon: category['icon'],
                          color: category['color'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'],
                        size: 40,
                        color: category['color'],
                      ),
                      SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: category['color'].withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SavingsDetailScreen extends StatefulWidget {
  final String categoryName;
  final IconData icon;
  final Color color;

  const SavingsDetailScreen({
    required this.categoryName,
    required this.icon,
    required this.color,
  });

  @override
  _SavingsDetailScreenState createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  void saveToFirestore() async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('savings');
      await collectionRef.add({
        'category': widget.categoryName,
        'amount': double.parse(amountController.text),
        'note': noteController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update budgeting screen logic here if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Savings added successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: widget.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(widget.icon, size: 80, color: widget.color),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Enter Note',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
              ),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
