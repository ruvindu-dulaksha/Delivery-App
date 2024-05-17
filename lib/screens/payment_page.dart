import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:savorease_app/screens/home_page.dart';

class PaymentPage extends StatelessWidget {
  final String userEmail;

  const PaymentPage(
      {Key? key, required this.userEmail, required String orderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: PaymentForm(userEmail: userEmail),
      ),
    );
  }
}

class PaymentForm extends StatefulWidget {
  final String userEmail;

  const PaymentForm({Key? key, required this.userEmail}) : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  late String _invoiceNumber;
  late DateTime _currentDateTime;
  late String _city;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCity();
  }

  Future<void> _fetchCity() async {
    try {
      // Query the addresses collection based on the user's email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('userEmail', isEqualTo: widget.userEmail)
          .get();

      // If there are documents returned, retrieve the city from the first document
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _city = querySnapshot.docs.first['city'];
        });
      } else {
        // No address found for the user
        print('No address found for user: ${widget.userEmail}');
        setState(() {
          _city = '';
        });
      }
    } catch (error) {
      print('Error fetching address: $error');
      setState(() {
        _city = '';
      });
    }
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
            primary: Colors.orange,
          ),
          child: Text('Pay'),
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

  void _processPayment(BuildContext context) {
    _showOTPDialog(context);
  }

  void _showOTPDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  counterText: '',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _verifyOTP(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _verifyOTP(BuildContext context) {
    // For demo purposes, assume OTP is correct
    if (_otpController.text == '123456') {
      Navigator.pop(context); // Close OTP dialog
      _invoiceNumber = _generateInvoiceNumber();
      _currentDateTime = DateTime.now();
      _showBillDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Bill'),
          content: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('orderId',
                    descending: true) // Order by order ID in descending order
                .limit(1)
                .get()
                .then((value) => value.docs.first),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                if (snapshot.hasError) {
                  return Text(
                      'Error fetching order details: ${snapshot.error}');
                } else {
                  var orderData = snapshot.data!.data() as Map<String, dynamic>;
                  List<dynamic> items = orderData['items'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Invoice Number: ${orderData['orderId']}'), // Use orderId as invoice number
                      Text(
                          'Date and Time: $_currentDateTime'), // Assuming you have a timestamp field in your order document
                      Text('Order Details:'),
                      for (var item in items)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Product: ${item['name']}'),
                            Text('Price: ${item['price']}'),
                            Text('Quantity: ${item['quantity']}'),
                            SizedBox(height: 10),
                          ],
                        ),
                      Text('Total Amount: ${orderData['totalPrice']}'),
                      Text('City: ${orderData['city']}'),
                      Text('User Email: ${orderData['userEmail']}'),
                    ],
                  );
                }
              }
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Get current date and time
                DateTime now = DateTime.now();
                String currentDateTime =
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

                // Fetch the latest order
                FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('orderId', descending: true)
                    .limit(1)
                    .get()
                    .then((value) {
                  if (value.docs.isNotEmpty) {
                    var latestOrderData =
                        value.docs.first.data() as Map<String, dynamic>;
                    // Store the order data in the purchase table along with the current date and time
                    FirebaseFirestore.instance.collection('purchase').add({
                      'invoiceNumber': latestOrderData['orderId'],
                      'dateTime': currentDateTime, // Use current date and time
                      'orderDetails': latestOrderData['items'],
                      'totalAmount': latestOrderData['totalPrice'],
                      'city': latestOrderData['city'],
                      'userEmail': latestOrderData['userEmail'],
                    }).then((purchaseRef) {
                      print('Order details stored in the purchase table.');

                      // Navigate to the home page and clear the route stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => false,
                      );
                    }).catchError((error) {
                      print('Error storing order details: $error');
                      // Handle error
                    });
                  } else {
                    print('No orders found');
                  }
                }).catchError((error) {
                  print('Error fetching latest order: $error');
                  // Handle error
                });
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    return 'INV-${now.year}${now.month}${now.day}-${now.hour}${now.minute}${now.second}';
  }
}
