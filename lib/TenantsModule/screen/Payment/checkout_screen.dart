// lib/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pay/pay.dart';
import 'dart:async';
import 'dart:io' show Platform;
// TODO: Uncomment these imports when you add the real API code
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'payment_configurations.dart'; // Import the file from Step 1.1

// Payment response model
class PaymentResponse {
  final bool isSuccess;
  final String? errorMessage;
  final String? errorCode;
  final PaymentErrorType? errorType;
  final Map<String, dynamic>? data;

  PaymentResponse({
    required this.isSuccess,
    this.errorMessage,
    this.errorCode,
    this.errorType,
    this.data,
  });
}

// Error types enum
enum PaymentErrorType {
  networkError,
  serverError,
  authenticationError,
  paymentFailed,
  validationError,
  timeoutError,
  unknownError,
  cancelledByUser,
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isPayPluginAvailable = false;
  bool _isCheckingPlugin = true;
  bool _isProcessingPayment = false;
  PaymentErrorType? _currentError;
  String? _errorMessage;
  bool _showSuccessMessage = false;

  final List<PaymentItem> _paymentItems = [
    const PaymentItem(
      label: 'Rent Payment',
      amount: '1.00', // This should be the final rent amount
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

    // Reset previous errors
    setState(() {
      _isProcessingPayment = true;
      _currentError = null;
      _errorMessage = null;
      _showSuccessMessage = false;
    });

    // 2. You MUST send this entire JSON object to your backend server for processing.
    // DO NOT process the payment directly in Flutter.

    try {
      final response = await sendPaymentTokenToServer(
        wallet: 'googlepay',
        paymentData: paymentResult,
        amount: '1.00',
      );

      // Handle server response
      if (response.isSuccess) {
        print("Payment successfully processed!");
        setState(() {
          _isProcessingPayment = false;
          _showSuccessMessage = true;
          _currentError = null;
          _errorMessage = null;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment processed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Handle different error types
        setState(() {
          _isProcessingPayment = false;
          _currentError = response.errorType ?? PaymentErrorType.unknownError;
          _errorMessage =
              response.errorMessage ?? 'Payment failed. Please try again.';
        });

        _showErrorSnackBar(_currentError!, _errorMessage!);
      }
    } catch (e) {
      print("Error communicating with backend: $e");
      setState(() {
        _isProcessingPayment = false;
        _currentError = PaymentErrorType.unknownError;
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });

      _showErrorSnackBar(PaymentErrorType.unknownError, _errorMessage!);
    }
  }

  // Function called after the user authorizes the payment in the Apple Pay sheet
  void onApplePayResult(Map<String, dynamic> paymentResult) async {
    // 1. The result contains the encrypted token (PaymentData JSON)
    print("Apple Pay Payment Result: $paymentResult");

    // Reset previous errors
    setState(() {
      _isProcessingPayment = true;
      _currentError = null;
      _errorMessage = null;
      _showSuccessMessage = false;
    });

    // 2. You MUST send this entire JSON object to your backend server for processing.
    // DO NOT process the payment directly in Flutter.

    try {
      final response = await sendPaymentTokenToServer(
        wallet: 'applepay',
        paymentData: paymentResult,
        amount: '1.00',
      );

      // Handle server response
      if (response.isSuccess) {
        print("Payment successfully processed!");
        setState(() {
          _isProcessingPayment = false;
          _showSuccessMessage = true;
          _currentError = null;
          _errorMessage = null;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment processed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Handle different error types
        setState(() {
          _isProcessingPayment = false;
          _currentError = response.errorType ?? PaymentErrorType.unknownError;
          _errorMessage =
              response.errorMessage ?? 'Payment failed. Please try again.';
        });

        _showErrorSnackBar(_currentError!, _errorMessage!);
      }
    } catch (e) {
      print("Error communicating with backend: $e");
      setState(() {
        _isProcessingPayment = false;
        _currentError = PaymentErrorType.unknownError;
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });

      _showErrorSnackBar(PaymentErrorType.unknownError, _errorMessage!);
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

  // Check if Apple Pay is available on the device
  Future<bool> _isApplePayAvailable() async {
    // Only check on iOS devices
    if (!Platform.isIOS) {
      print("Apple Pay: Not iOS device, skipping");
      return false;
    }

    try {
      // Try to create a payment configuration to test availability
      PaymentConfiguration.fromJsonString(
        defaultApplePayConfigString,
      );
      // If we can create the config, Apple Pay might be available
      // Note: Actual availability is checked by the button itself
      // The button will handle its own availability check
      print("Apple Pay: Configuration created successfully");
      return true;
    } catch (e) {
      print("Apple Pay: Configuration error - $e");
      return false;
    }
  }

  // Function for sending data to your server with comprehensive error handling
  // TODO: Uncomment and implement the actual API call when ready
  Future<PaymentResponse> sendPaymentTokenToServer({
    required String wallet,
    required Map<String, dynamic> paymentData,
    required String amount,
  }) async {
    // ============================================
    // PLACEHOLDER CODE - Replace with real API call
    // ============================================
    // Simulating API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock success response for testing
    // Remove this and uncomment the API code below when ready
    return PaymentResponse(
      isSuccess: true,
      data: {'message': 'Payment processed successfully (mock response)'},
    );

    // ============================================
    // REAL API CODE - Uncomment when ready to use
    // ============================================
    /*
    try {
      // **TODO: Replace with your actual backend API URL**
      final url = Uri.parse('YOUR_BACKEND_API_URL/charge-nmi');

      // Add authentication headers if needed
      // final token = await _getAuthToken();

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Uncomment if auth is needed
        },
        body: jsonEncode({
          'wallet': wallet,
          'paymentData': paymentData, // The raw token JSON
          'amount': amount,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle different HTTP status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        if (responseData['success'] == true ||
            responseData['status'] == 'success' ||
            responseData['status'] == 'approved') {
          return PaymentResponse(
            isSuccess: true,
            data: responseData,
          );
        } else {
          // Payment was processed but failed (e.g., declined card)
          return PaymentResponse(
            isSuccess: false,
            errorType: PaymentErrorType.paymentFailed,
            errorMessage: responseData['message'] ??
                responseData['error'] ??
                'Payment was declined. Please check your payment method.',
            errorCode: responseData['error_code']?.toString(),
            data: responseData,
          );
        }
      } else if (response.statusCode == 400) {
        // Bad Request - Validation error
        return PaymentResponse(
          isSuccess: false,
          errorType: PaymentErrorType.validationError,
          errorMessage: responseData['message'] ??
              responseData['error'] ??
              'Invalid payment information. Please check your details.',
          errorCode: responseData['error_code']?.toString(),
          data: responseData,
        );
      } else if (response.statusCode == 401) {
        // Unauthorized - Authentication error
        return PaymentResponse(
          isSuccess: false,
          errorType: PaymentErrorType.authenticationError,
          errorMessage: 'Authentication failed. Please log in again.',
          errorCode: '401',
          data: responseData,
        );
      } else if (response.statusCode == 403) {
        // Forbidden - Authorization error
        return PaymentResponse(
          isSuccess: false,
          errorType: PaymentErrorType.authenticationError,
          errorMessage: 'You do not have permission to perform this action.',
          errorCode: '403',
          data: responseData,
        );
      } else if (response.statusCode >= 500) {
        // Server error
        return PaymentResponse(
          isSuccess: false,
          errorType: PaymentErrorType.serverError,
          errorMessage: responseData['message'] ??
              'Server error occurred. Please try again later.',
          errorCode: response.statusCode.toString(),
          data: responseData,
        );
      } else {
        // Other client errors (404, etc.)
        return PaymentResponse(
          isSuccess: false,
          errorType: PaymentErrorType.serverError,
          errorMessage:
              responseData['message'] ?? 'An error occurred. Please try again.',
          errorCode: response.statusCode.toString(),
          data: responseData,
        );
      }
    } on SocketException {
      // Network error - no internet connection
      return PaymentResponse(
        isSuccess: false,
        errorType: PaymentErrorType.networkError,
        errorMessage:
            'No internet connection. Please check your network and try again.',
        errorCode: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      // HTTP error
      return PaymentResponse(
        isSuccess: false,
        errorType: PaymentErrorType.networkError,
        errorMessage: 'Network error: ${e.message}',
        errorCode: 'HTTP_ERROR',
      );
    } on TimeoutException {
      // Timeout error
      return PaymentResponse(
        isSuccess: false,
        errorType: PaymentErrorType.timeoutError,
        errorMessage:
            'Request timed out. Please check your connection and try again.',
        errorCode: 'TIMEOUT',
      );
    } on FormatException {
      // JSON parsing error
      return PaymentResponse(
        isSuccess: false,
        errorType: PaymentErrorType.serverError,
        errorMessage: 'Invalid response from server. Please try again.',
        errorCode: 'PARSE_ERROR',
      );
    } catch (e) {
      // Unknown error
      return PaymentResponse(
        isSuccess: false,
        errorType: PaymentErrorType.unknownError,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
    */
  }

  // Helper function to show error snackbar with appropriate styling
  void _showErrorSnackBar(PaymentErrorType errorType, String message) {
    if (!mounted) return;

    Color backgroundColor;
    IconData icon;
    String title;

    switch (errorType) {
      case PaymentErrorType.networkError:
        backgroundColor = Colors.orange;
        icon = Icons.wifi_off;
        title = 'Network Error';
        break;
      case PaymentErrorType.serverError:
        backgroundColor = Colors.red;
        icon = Icons.error_outline;
        title = 'Server Error';
        break;
      case PaymentErrorType.authenticationError:
        backgroundColor = Colors.amber;
        icon = Icons.lock_outline;
        title = 'Authentication Error';
        break;
      case PaymentErrorType.paymentFailed:
        backgroundColor = Colors.red;
        icon = Icons.payment;
        title = 'Payment Failed';
        break;
      case PaymentErrorType.validationError:
        backgroundColor = Colors.orange;
        icon = Icons.info_outline;
        title = 'Validation Error';
        break;
      case PaymentErrorType.timeoutError:
        backgroundColor = Colors.orange;
        icon = Icons.timer_off;
        title = 'Timeout Error';
        break;
      case PaymentErrorType.cancelledByUser:
        backgroundColor = Colors.grey;
        icon = Icons.cancel_outlined;
        title = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.red;
        icon = Icons.error;
        title = 'Error';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Build error display widget
  Widget _buildErrorDisplay() {
    if (_currentError == null) return const SizedBox.shrink();

    Color errorColor;
    IconData errorIcon;
    String errorTitle;

    switch (_currentError!) {
      case PaymentErrorType.networkError:
        errorColor = Colors.orange;
        errorIcon = Icons.wifi_off;
        errorTitle = 'Network Error';
        break;
      case PaymentErrorType.serverError:
        errorColor = Colors.red;
        errorIcon = Icons.error_outline;
        errorTitle = 'Server Error';
        break;
      case PaymentErrorType.authenticationError:
        errorColor = Colors.amber;
        errorIcon = Icons.lock_outline;
        errorTitle = 'Authentication Error';
        break;
      case PaymentErrorType.paymentFailed:
        errorColor = Colors.red;
        errorIcon = Icons.payment;
        errorTitle = 'Payment Failed';
        break;
      case PaymentErrorType.validationError:
        errorColor = Colors.orange;
        errorIcon = Icons.info_outline;
        errorTitle = 'Validation Error';
        break;
      case PaymentErrorType.timeoutError:
        errorColor = Colors.orange;
        errorIcon = Icons.timer_off;
        errorTitle = 'Timeout Error';
        break;
      case PaymentErrorType.cancelledByUser:
        errorColor = Colors.grey;
        errorIcon = Icons.cancel_outlined;
        errorTitle = 'Payment Cancelled';
        break;
      default:
        errorColor = Colors.red;
        errorIcon = Icons.error;
        errorTitle = 'Error';
    }

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        border: Border.all(color: errorColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(errorIcon, size: 48, color: errorColor),
          const SizedBox(height: 12),
          Text(
            errorTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: errorColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentError = null;
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Build success display widget
  Widget _buildSuccessDisplay() {
    if (!_showSuccessMessage) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 48, color: Colors.green),
          const SizedBox(height: 12),
          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your payment has been processed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, true); // Return success
            },
            icon: const Icon(Icons.done),
            label: const Text('Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text('Your Rent Due: \$1.00',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Show processing indicator
              if (_isProcessingPayment)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Processing payment...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                )
              else if (_isCheckingPlugin)
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
                // Payment buttons section - shows both Google Pay and Apple Pay
                Column(
                  children: [
                    // Google Pay Button
                    FutureBuilder<bool>(
                      future: _isGooglePayAvailable(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        if (snapshot.hasError || !(snapshot.data ?? false)) {
                          return const SizedBox.shrink();
                        }

                        // Show Google Pay Button
                        try {
                          return GooglePayButton(
                            paymentConfiguration:
                                PaymentConfiguration.fromJsonString(
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
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    // Apple Pay Button (iOS only)
                    if (Platform.isIOS)
                      Column(
                        children: [
                          Builder(
                            builder: (context) {
                              // Always try to show the button on iOS
                              // The button itself will handle availability
                              // If it's not available, the button won't render
                              try {
                                print("Apple Pay: Attempting to show button");
                                final button = ApplePayButton(
                                  paymentConfiguration:
                                      PaymentConfiguration.fromJsonString(
                                    defaultApplePayConfigString,
                                  ),
                                  paymentItems: _paymentItems,
                                  type: ApplePayButtonType.buy,
                                  margin: const EdgeInsets.only(top: 15.0),
                                  onPaymentResult: onApplePayResult,
                                  loadingIndicator: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                // Wrap in a container to ensure it takes space
                                return Container(
                                  margin: const EdgeInsets.only(top: 15.0),
                                  constraints: const BoxConstraints(
                                    minHeight: 50,
                                  ),
                                  child: button,
                                );
                              } catch (e, stackTrace) {
                                print("Apple Pay: Error creating button - $e");
                                print("Apple Pay: Stack trace - $stackTrace");
                                // Show error message instead of hiding
                                return Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.orange,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Apple Pay Error: $e',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Please ensure:\n'
                                        '1. Apple Pay capability is enabled in Xcode\n'
                                        '2. Merchant identifier is configured\n'
                                        '3. App is properly signed',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          // Debug info - shows if button might not be rendering
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'If Apple Pay button is not visible, check Xcode configuration',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    // Show message if no payment methods are available
                    FutureBuilder<List<bool>>(
                      future: Future.wait([
                        _isGooglePayAvailable(),
                        _isApplePayAvailable(),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final googlePayAvailable = snapshot.data?[0] ?? false;
                        final applePayAvailable = snapshot.data?[1] ?? false;

                        if (!googlePayAvailable && !applePayAvailable) {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              const Icon(
                                Icons.info_outline,
                                size: 64,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Payment Methods Not Available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  Platform.isIOS
                                      ? 'Apple Pay is not available.\n\n'
                                          'Please check:\n'
                                          '1. Apple Pay is set up in Settings > Wallet & Apple Pay\n'
                                          '2. You have a card added to Apple Pay\n'
                                          '3. Apple Pay capability is enabled in Xcode\n'
                                          '4. Merchant identifier is configured in Xcode\n'
                                          '5. App is signed with proper provisioning profile'
                                      : 'Google Pay and Apple Pay are not available on this device.\n'
                                          'Make sure you are testing on a real device\n'
                                          'with the required payment services installed.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
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

                        return const SizedBox.shrink();
                      },
                    ),
                    // Show error display if there's an error
                    _buildErrorDisplay(),
                    // Show success display if payment succeeded
                    _buildSuccessDisplay(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
