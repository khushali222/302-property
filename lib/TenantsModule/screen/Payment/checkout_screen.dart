// lib/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pay/pay.dart';
import 'payment_configurations.dart'; // Import the file from Step 1.1

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isPayPluginAvailable = false;
  bool _isCheckingPlugin = true;
  final List<PaymentItem> _paymentItems = [
    const PaymentItem(
      label: 'Rent Payment',
      amount: '19.99', // This should be the final rent amount
      status: PaymentItemStatus.final_price,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkPayPluginAvailability();
  }

  // Check if pay plugin is available
  Future<void> _checkPayPluginAvailability() async {
    try {
      // Try to check if the platform channel is available
      // Creating the MethodChannel to test availability
      const MethodChannel('plugins.flutter.io/pay/payment_result');

      // For testing, we'll assume plugin is available if we can create the channel
      // The actual availability will be checked when the button tries to render
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isPayPluginAvailable = true;
        _isCheckingPlugin = false;
      });
    } catch (e) {
      // Plugin not available
      setState(() {
        _isPayPluginAvailable = false;
        _isCheckingPlugin = false;
      });
    }
  }

  // Function called after the user authorizes the payment in the Google Pay sheet
  void onGooglePayResult(Map<String, dynamic> paymentResult) async {
    // 1. The result contains the encrypted token (PaymentData JSON)
    print("Google Pay Payment Result: $paymentResult");

    // 2. You MUST send this entire JSON object to your backend server for processing.
    // DO NOT process the payment directly in Flutter.

    // Example call to your backend (you'll need an actual HTTP client like 'dio' or 'http')
    try {
      final response = await sendPaymentTokenToServer(
        wallet: 'googlepay',
        paymentData: paymentResult,
        amount: '19.99',
      );

      // Handle server response (e.g., show success/failure message)
      if (response.isSuccess) {
        print("Payment successfully processed by NMI!");
      } else {
        print("Payment failed: ${response.errorMessage}");
      }
    } catch (e) {
      print("Error communicating with backend: $e");
    }
  }

  // Check if Google Pay is available on the device
  Future<bool> _isGooglePayAvailable() async {
    try {
      // Try to create a payment configuration to test availability
      PaymentConfiguration.fromJsonString(
        defaultGooglePayConfigString,
      );
      // If we can create the config, Google Pay might be available
      // Note: Actual availability is checked by the button itself
      return true;
    } catch (e) {
      return false;
    }
  }

  // Placeholder function for sending data to your server
  Future<dynamic> sendPaymentTokenToServer(
      {required String wallet,
      required Map<String, dynamic> paymentData,
      required String amount}) async {
    // **TODO: Implement actual API call to your backend**
    // Use the http package to POST the data:
    /*
    final url = Uri.parse('YOUR_BACKEND_API_URL/charge-nmi');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'wallet': wallet,
        'paymentData': paymentData, // The raw token JSON
        'amount': amount,
      }),
    );
    return jsonDecode(response.body); // Return the NMI response
    */
    // For now, return a mock success response:
    await Future.delayed(const Duration(seconds: 2));
    return (isSuccess: true, errorMessage: null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your Rent Due: \$19.99',
                style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            if (_isCheckingPlugin)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (!_isPayPluginAvailable)
              // Fallback UI when plugin is not available
              Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Plugin Not Available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Please rebuild the app to enable payment functionality.\n\n'
                      'Steps to fix:\n'
                      '1. Stop the app completely\n'
                      '2. Run: flutter clean\n'
                      '3. Run: flutter pub get\n'
                      '4. Rebuild and run the app',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              )
            else
              // The Google Pay Button (only shown when plugin is available)
              FutureBuilder<bool>(
                future: _isGooglePayAvailable(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !(snapshot.data ?? false)) {
                    return Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Google Pay Not Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Google Pay is not available on this device.\n'
                            'Make sure you are testing on a real Android device\n'
                            'with Google Play Services installed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go Back'),
                        ),
                      ],
                    );
                  }

                  // Show Google Pay Button
                  try {
                    return GooglePayButton(
                      paymentConfiguration: PaymentConfiguration.fromJsonString(
                        defaultGooglePayConfigString,
                      ),
                      paymentItems: _paymentItems,
                      type: GooglePayButtonType.pay,
                      margin: const EdgeInsets.only(top: 15.0),
                      onPaymentResult: onGooglePayResult,
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } catch (e) {
                    return Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error Loading Payment Button',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: $e',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go Back'),
                        ),
                      ],
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
