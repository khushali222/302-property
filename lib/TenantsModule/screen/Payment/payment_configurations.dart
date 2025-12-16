// lib/payment_configurations.dart
//
// NOTE: These configurations support both TEST and PRODUCTION environments
// For production, set PAYMENT_ENVIRONMENT to 'PRODUCTION' below

// ============================================================================
// ENVIRONMENT CONFIGURATION
// ============================================================================
// Change this to switch between TEST and PRODUCTION environments
// TEST: Use for development and testing (works without Google Pay Console registration)
// PRODUCTION: Use for live payments (requires Google Pay Console merchant registration)
const String PAYMENT_ENVIRONMENT =
    'TEST'; // Set to 'PRODUCTION' for live payments

/// Generate Google Pay configuration dynamically with merchant ID and amount
String generateGooglePayConfig({
  required String merchantId,
  required String amount,
  String merchantName = 'Cloud Rental Manager',
  String? environment, // If null, uses PAYMENT_ENVIRONMENT constant
  String currencyCode = 'USD',
  String countryCode = 'US',
}) {
  // Use provided environment or fall back to constant
  final String env = environment ?? PAYMENT_ENVIRONMENT;
  return '''
{
  "provider": "google_pay",
  "data": {
    "environment": "$env",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER", "JCB"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "gatewayservices",
            "gatewayMerchantId": "$merchantId"
          }
        }
      }
    ],
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "$amount",
      "totalPriceLabel": "Total",
      "currencyCode": "$currencyCode",
      "countryCode": "$countryCode"
    },
    "merchantInfo": {
      "merchantName": "$merchantName",
      "merchantId": "$merchantId"
    }
  }
}
''';
}

/// Generate Apple Pay configuration dynamically with amount
///
/// NOTE: Apple Pay does NOT require environment configuration (TEST/PRODUCTION)
/// Apple Pay automatically uses the correct environment based on:
/// - App signing (development vs production provisioning profile)
/// - App Store vs TestFlight vs development builds
///
/// Important: merchantIdentifier must match the one in iOS entitlements file
/// This is the Apple Merchant ID, NOT the NMI merchant
///
///
///
///
String generateApplePayConfig({
  required String amount,
  String merchantName = 'Cloud Rental Manager',
  String merchantIdentifier =
      'merchant.com.hostmerchantservices.cloudrentalmanager',
  String currencyCode = 'USD',
  String countryCode = 'US',
}) {
  return '''
{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "$merchantIdentifier",
    "displayName": "$merchantName",
    "merchantCapabilities": ["3DS", "debit", "credit"],
    "supportedNetworks": ["visa", "masterCard", "amex", "discover"],
    "countryCode": "$countryCode",
    "currencyCode": "$currencyCode"
  }
}
''';
}

// Default static configurations (fallback)
const String defaultGooglePayConfigString = '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER", "JCB"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "gatewayservices",
            "gatewayMerchantId": "exampleGatewayMerchantId"
          }
        }
      }
    ],
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "1.00",
      "totalPriceLabel": "Total",
      "currencyCode": "USD",
      "countryCode": "US"
    },
    "merchantInfo": {
      "merchantName": "Cloud Rental Manager",
      "merchantId": "BCR2DN6TZ7QZ4XQZ"
    }
  }
}
''';

const String defaultApplePayConfigString = '''
{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.hostmerchantservices.cloudrentalmanager",
    "displayName": "Cloud Rental Manager",
    "merchantCapabilities": ["3DS", "debit", "credit"],
    "supportedNetworks": ["visa", "masterCard", "amex", "discover"],
    "countryCode": "US",
    "currencyCode": "USD"
  }
}
''';
