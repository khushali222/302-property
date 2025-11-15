import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../models/payment_settings_model.dart';

class PaymentMethodDropdown extends StatelessWidget {
  final PaymentSettingsModel? paymentSettings;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final bool isLoading;
  final String? error;

  const PaymentMethodDropdown({
    Key? key,
    required this.paymentSettings,
    required this.selectedValue,
    required this.onChanged,
    this.isLoading = false,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Text(
        error!,
        style: const TextStyle(color: Colors.red),
      );
    }

    if (paymentSettings == null) {
      return const SizedBox.shrink();
    }

    if (!paymentSettings!.hasAnyPaymentMethod) {
      return const Text(
        'No payment methods available',
        style: TextStyle(color: Colors.red),
      );
    }

    final List<DropdownMenuItem<String>> items = [];

    if (paymentSettings!.acceptCard) {
      items.add(const DropdownMenuItem(
          value: 'Card', child: Text('Credit/Debit Card')));
    }
    if (paymentSettings!.acceptACH) {
      items.add(const DropdownMenuItem(
          value: 'ACH', child: Text('ACH/Bank Transfer')));
    }
    if (paymentSettings!.acceptCash) {
      items.add(const DropdownMenuItem(value: 'Cash', child: Text('Cash')));
    }
    if (paymentSettings!.acceptCheck) {
      items.add(const DropdownMenuItem(value: 'Check', child: Text('Check')));
    }

    return DropdownButton2<String>(
      isExpanded: true,
      hint: const Text('Select Payment Method'),
      items: items,
      value: selectedValue,
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
