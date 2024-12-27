import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
      {'title': 'Transport', 'icon': Icons.directions_bus, 'color': Colors.blue},
      {'title': 'Entertainment', 'icon': Icons.movie, 'color': Colors.red},
      {'title': 'Hospital', 'icon': Icons.local_hospital, 'color': Colors.pink},
      {'title': 'Education', 'icon': Icons.school, 'color': Colors.green},
      {'title': 'Bill', 'icon': Icons.receipt, 'color': Colors.purple},
      {'title': 'Loan', 'icon': Icons.money, 'color': Colors.teal},
      {'title': 'Medicine', 'icon': Icons.medication, 'color': Colors.cyan},
      {'title': 'Others', 'icon': Icons.category, 'color': Colors.grey},
      {'title': 'Shopping', 'icon': Icons.shopping_cart, 'color': Colors.brown},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              color: category['color'] as Color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    category['title'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
