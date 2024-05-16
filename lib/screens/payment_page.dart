import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:savorease_app/screens/branch_admin.dart';

class PaymentPage extends StatelessWidget {
  final String city;

  const PaymentPage({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: PaymentForm(city: city),
      ),
    );
  }
}

class PaymentForm extends StatefulWidget {
  final String city;

  const PaymentForm({Key? key, required this.city}) : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isPaymentSuccess = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
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
          onPressed: () {
            _processPayment(context);
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.orange, // Orange button color
          ),
          child: Text('Pay'),
        ),
        SizedBox(height: 10),
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
                String invoiceNumber = _generateInvoiceNumber();
                _showSuccessDialog(
                    context, invoiceNumber); // Pass invoice number
                _storePaymentDetails(
                    context); // Store payment details in Firestore
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
                String invoiceNumber = _generateInvoiceNumber();
                _showSuccessDialog(
                    context, invoiceNumber); // Pass invoice number
                _storePaymentDetails(
                    context); // Store payment details in Firestore
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String invoiceNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.city)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return AlertDialog(
                  title: Text('Error'),
                  content:
                      Text('Error fetching order details: ${snapshot.error}'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Close the payment page
                        _navigateToAdminDashboard(
                            context); // Navigate to branch admin page dashboard
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              } else {
                if (snapshot.data != null && snapshot.data!.exists) {
                  Map<String, dynamic> orderData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return AlertDialog(
                    title: Text('Payment Successful'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Date: ${DateTime.now()}'),
                        Text('Invoice Number: $invoiceNumber'),
                        // Display order details here
                        Text('Order Details:'),
                        Text('Products: ${orderData['products'].join(', ')}'),
                        Text('Total Amount: ${orderData['total_price']}'),
                        Text('City: ${orderData['city']}'),
                        Text('Address: ${orderData['address']}'),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          Navigator.pop(context); // Close the payment page
                          _navigateToAdminDashboard(
                              context); // Navigate to branch admin page dashboard
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('No order found for city: ${widget.city}'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          Navigator.pop(context); // Close the payment page
                          _navigateToAdminDashboard(
                              context); // Navigate to branch admin page dashboard
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                }
              }
            }
          },
        );
      },
    );
  }

  String _generateInvoiceNumber() {
    // Generate a unique invoice number
    final now = DateTime.now();
    return 'INV-${now.year}${now.month}${now.day}-${now.hour}${now.minute}${now.second}';
  }

  void _storePaymentDetails(BuildContext context) async {
    // Generate a unique invoice number
    String invoiceNumber = _generateInvoiceNumber();

    // Store payment details in the purchase collection
    await FirebaseFirestore.instance.collection('purchase').add({
      'payment_date': DateTime.now(),
      'invoice_number': invoiceNumber,

      'city': widget.city,
      // Add other payment details as needed
    });

    // Mark the payment as successful
    setState(() {
      _isPaymentSuccess = true;
    });
  }

  void _navigateToAdminDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BranchAdminDashboardPage()),
    );
  }
}
