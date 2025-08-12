import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CardTypeSelector extends StatefulWidget {
  final bool creditCardAccepted;
  final bool debitCardAccepted;
  final Function(String) onCardTypeSelected;

  const CardTypeSelector({
    Key? key,
    required this.creditCardAccepted,
    required this.debitCardAccepted,
    required this.onCardTypeSelected,
  }) : super(key: key);

  @override
  _CardTypeSelectorState createState() => _CardTypeSelectorState();
}

class _CardTypeSelectorState extends State<CardTypeSelector> {
  String? selectedCardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Card Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCardTypeOption(
              'Credit Card',
              'credit',
              widget.creditCardAccepted,
            ),
            const SizedBox(width: 16),
            _buildCardTypeOption(
              'Debit Card',
              'debit',
              widget.debitCardAccepted,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardTypeOption(String label, String type, bool isAccepted) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isAccepted) {
            Fluttertoast.showToast(
              msg: "$label payments are not accepted by the rental owner",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
            return;
          }
          setState(() {
            selectedCardType = type;
          });
          widget.onCardTypeSelected(type);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedCardType == type
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              width: selectedCardType == type ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: !isAccepted ? Colors.grey.shade200 : null,
          ),
          child: Column(
            children: [
              Icon(
                Icons.credit_card,
                color:
                    !isAccepted ? Colors.grey : Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: !isAccepted ? Colors.grey : Colors.black,
                  fontWeight: selectedCardType == type
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (!isAccepted)
                const Text(
                  '(Not Available)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

