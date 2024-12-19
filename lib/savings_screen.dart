import 'package:flutter/material.dart';

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
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,  // Ensures the grid doesn't take more space than necessary
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
                    // Navigate to detailed savings screen for this category
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

class SavingsDetailScreen extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color color;

  const SavingsDetailScreen({
    required this.categoryName,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: color,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            SizedBox(height: 16),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This is your detailed page for $categoryName savings.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
              ),
              child: Text('Back to Savings Categories'),
            ),
          ],
        ),
      ),
    );
  }
}
