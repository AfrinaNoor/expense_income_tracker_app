import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController amountController = TextEditingController();
  String selectedCurrency = 'USD';
  double conversionRate = 85.0; // Example conversion rate for USD to BDT

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Enter Amount in $selectedCurrency',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCurrency,
              items: ['USD', 'EUR', 'INR', 'GBP'].map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (String? newCurrency) {
                setState(() {
                  selectedCurrency = newCurrency!;
                  // Update conversion rate based on selected currency
                  // Example: You can integrate live APIs to fetch real rates
                  if (selectedCurrency == 'USD') {
                    conversionRate = 85.0;
                  } else if (selectedCurrency == 'EUR') {
                    conversionRate = 90.0;
                  }
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0;
                double convertedAmount = amount * conversionRate;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Converted Amount'),
                    content: Text('$amount $selectedCurrency = $convertedAmount BDT'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Convert to BDT'),
            ),
          ],
        ),
      ),
    );
  }
}
