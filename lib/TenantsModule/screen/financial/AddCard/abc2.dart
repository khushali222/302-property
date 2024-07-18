import 'package:flutter/material.dart';
import 'dart:math';

class CreditCardsPage extends StatefulWidget {
  @override
  _CreditCardsPageState createState() => _CreditCardsPageState();
}

class _CreditCardsPageState extends State<CreditCardsPage> {
  List<Map<String, String>> cardDetails = [
    {
      "cardExpiration": "08/2022",
      "cardHolder": "HOUSSEM SELMI",
      "cardNumber": "3546753297421212",
    },
    {
      "cardExpiration": "05/2024",
      "cardHolder": "HOUSSEM SELMI",
      "cardNumber": "9874478565481231",
    },
  ];

  void _showAddCardDialog() {
    final cardHolderController = TextEditingController();
    final cardNumberController = TextEditingController();
    final cardExpirationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardHolderController,
                decoration: InputDecoration(labelText: 'Card Holder'),
              ),
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(labelText: 'Card Number'),
              ),
              TextField(
                controller: cardExpirationController,
                decoration: InputDecoration(labelText: 'Expiration Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cardDetails.add({
                    "cardExpiration": cardExpirationController.text,
                    "cardHolder": cardHolderController.text,
                    "cardNumber": cardNumberController.text,
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _formatCardNumber(String cardNumber) {
    if (cardNumber.length != 16) {
      return cardNumber; // If the card number length is not 16, return as-is
    }

    String maskedNumber = '';

    // Show the first character
    maskedNumber += cardNumber.substring(0, 1);

    // Add spaces after every 4 characters
    for (int i = 1; i < cardNumber.length - 4; i++) {
      if (i % 4 == 0) {
        maskedNumber += ' ';
      }
      maskedNumber += 'x'; // Mask middle digits with 'x'
    }

    // Show the last 4 characters
    maskedNumber += ' ' + cardNumber.substring(cardNumber.length - 4);

    return maskedNumber;
  }



  Color _generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTitleSection(
                title: "Payment Details",
                subTitle: "How would you like to pay?"),
            ...cardDetails.map((details) {
              return _buildCreditCard(
                color: _generateRandomColor(),
                cardExpiration: details["cardExpiration"]!,
                cardHolder: details["cardHolder"]!,
                cardNumber: _formatCardNumber(details["cardNumber"]!),
              );
            }).toList(),
            _buildAddCardButton(
              icon: Icon(Icons.add),
              color: Color(0xFF081603),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildTitleSection({required String title, required String subTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            subTitle,
            style: TextStyle(fontSize: 21, color: Colors.black45),
          ),
        ),
      ],
    );
  }

  Card _buildCreditCard(
      {required Color color,
        required String cardNumber,
        required String cardHolder,
        required String cardExpiration}) {
    return Card(
      elevation: 4.0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        height: 200,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLogosBlock(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                cardNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontFamily: 'CourierPrime',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildDetailsBlock(
                  label: 'CARDHOLDER',
                  value: cardHolder,
                ),
                _buildDetailsBlock(label: 'VALID THRU', value: cardExpiration),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row _buildLogosBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Image.asset(
          "assets/images/contact_less.png",
          height: 20,
          width: 18,
        ),
        Image.asset(
          "assets/images/mastercard.png",
          height: 50,
          width: 50,
        ),
      ],
    );
  }

  Column _buildDetailsBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Container _buildAddCardButton({
    required Icon icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 24.0),
      alignment: Alignment.center,
      child: FloatingActionButton(
        elevation: 2.0,
        onPressed: _showAddCardDialog,
        backgroundColor: color,
        mini: false,
        child: icon,
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Cards Project',
      theme: ThemeData(fontFamily: 'Lato'),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(child: CreditCardsPage()),
      ),
    );
  }
}
