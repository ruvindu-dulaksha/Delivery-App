import 'package:flutter/material.dart';
import 'package:savorease_app/screens/home_page.dart';

class PaymentPage extends StatelessWidget {
  final String userEmail;
  final String orderId;

  const PaymentPage({Key? key, required this.userEmail, required this.orderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: PaymentForm(userEmail: userEmail, orderId: orderId),
      ),
    );
  }
}

class PaymentForm extends StatefulWidget {
  final String userEmail;
  final String orderId;

  const PaymentForm({Key? key, required this.userEmail, required this.orderId})
      : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isPaymentProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _otpController.dispose();
    super.dispose();
  }

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
        ElevatedButton(
          onPressed: _isPaymentProcessing ? null : _showOTPDialog,
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
          ),
          child: Text('Pay Here'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
          child: Text('Cancel'),
        ),
      ],
    );
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: TextField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: 'OTP',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _submitPayment();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitPayment() {
    // Simulate payment processing
    setState(() {
      _isPaymentProcessing = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      _showPaymentSuccessDialog(context);
      setState(() {
        _isPaymentProcessing = false;
      });
    });
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Successful'),
          content: Text('Your payment has been processed successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                ); // Navigate back to home page
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
