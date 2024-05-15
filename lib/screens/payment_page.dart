import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.orange, // Orange button color
          ),
          child: Text('Make Payment'),
        ),
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: PaymentForm(),
      ),
    );
  }
}

class PaymentForm extends StatefulWidget {
  const PaymentForm({Key? key}) : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isPaymentSuccess = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _expiryDateController,
          decoration: InputDecoration(
            labelText: 'Expiry Date',
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _cvvController,
          decoration: InputDecoration(
            labelText: 'CVV',
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Total Amount',
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _processPayment(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // Orange button color
              ),
              child: Text('Pay'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Red button color
              ),
              child: Text('Cancel'),
            ),
          ],
        ),
        _isPaymentSuccess
            ? AlertDialog(
                title: Text('Payment Successful'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Date: ${DateTime.now()}'),
                    Text('Invoice Number: ABC123'),
                    Text('Product: Product Name'),
                    Text('Total Amount: ${_amountController.text}'),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Close the payment page
                    },
                    child: Text('Close'),
                  ),
                ],
              )
            : SizedBox.shrink(),
      ],
    );
  }

  void _processPayment(BuildContext context) {
    // Simulate OTP verification
    _showOTPDialog(context);
  }

  void _showOTPDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: TextField(
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value) {
              // For demo purposes, automatically validate OTP
              if (value == '123456') {
                Navigator.pop(context); // Close OTP dialog
                _showSuccessDialog(context);
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter OTP',
              counterText: '', // Hide character counter
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Navigate to bill page
                Navigator.pop(context); // Close OTP dialog
                _showSuccessDialog(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Date: ${DateTime.now()}'),
              Text('Invoice Number: ABC123'),
              Text('Product: Product Name'),
              Text('Total Amount: ${_amountController.text}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Close the payment page
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
