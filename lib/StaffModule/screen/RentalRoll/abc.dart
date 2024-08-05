import 'package:flutter/material.dart';

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
      "cc_type": "mastercard",
    },
    {
      "cardExpiration": "05/2024",
      "cardHolder": "HOUSSEM SELMI",
      "cardNumber": "9874478565481231",
      "cc_type": "visa",
    },
  ];

  void _showAddCardDialog() {
    final cardHolderController = TextEditingController();
    final cardNumberController = TextEditingController();
    final cardExpirationController = TextEditingController();
    final cardTypeController = TextEditingController();

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
              TextField(
                controller: cardTypeController,
                decoration: InputDecoration(labelText: 'Card Type'),
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
                    "cc_type": cardTypeController.text,
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

  void _deleteCard(int index) {
    setState(() {
      cardDetails.removeAt(index);
    });
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

  LinearGradient _getCardGradient(String cardType) {
    if (cardType.toLowerCase() == "mastercard" ||
        cardType.toLowerCase() == "discover") {
      return LinearGradient(
        colors: [Color(0xFF121E2E), Color(0xFF3A6194)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (cardType.toLowerCase() == "visa" ||
        cardType.toLowerCase() == "jcb") {
      return LinearGradient(
        colors: [Color(0xFF000000), Color(0xFF666666)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [Color(0xFF949BA5), Color(0xFF393B3F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: cardDetails.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> details = entry.value;
                        return Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildCreditCard(
                                  gradient:
                                      _getCardGradient(details["cc_type"]!),
                                  cardExpiration: details["cardExpiration"]!,
                                  cardHolder: details["cardHolder"]!,
                                  cardNumber:
                                      _formatCardNumber(details["cardNumber"]!),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCard(index),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    _buildAddCardButton(
                      icon: Icon(Icons.add),
                      color: Color(0xFF081603),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // _buildTitleSection(
                    //   title: "Payment Details",
                    //   subTitle: "How would you like to pay?",
                    // ),
                    ...cardDetails.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> details = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildCreditCard(
                              gradient: _getCardGradient(details["cc_type"]!),
                              cardExpiration: details["cardExpiration"]!,
                              cardHolder: details["cardHolder"]!,
                              cardNumber:
                                  _formatCardNumber(details["cardNumber"]!),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCard(index),
                          ),
                        ],
                      );
                    }).toList(),
                    _buildAddCardButton(
                      icon: Icon(Icons.add),
                      color: Color(0xFF081603),
                    ),
                  ],
                ),
              );
            }
          },
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

  Card _buildCreditCard({
    required LinearGradient gradient,
    required String cardNumber,
    required String cardHolder,
    required String cardExpiration,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        height: 200,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
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
          "assets/images/contactless1.png",
          height: 30,
          width: 30,
        ),
        Image.asset(
          "assets/visa.png",
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
              color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
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
