// lib/payment_configurations.dart
//
// NOTE: These configurations are set up for TEST/SANDBOX environment
// For production, update the environment and merchant credentials accordingly

/// Generate Google Pay configuration dynamically with merchant ID and amount
String generateGooglePayConfig({
  required String merchantId,
  required String amount,
  String merchantName = 'Cloud Rental Manager',
  String environment = 'TEST', // Change to 'PRODUCTION' for live
  String currencyCode = 'USD',
  String countryCode = 'US',
}) {
  return '''
{
  "provider": "google_pay",
  "data": {
    "environment": "$environment",
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

/// Generate Apple Pay configuration dynamically with merchant ID and amount
String generateApplePayConfig({
  required String merchantId,
  required String amount,
  String merchantName = 'Cloud Rental Manager',
  String currencyCode = 'USD',
  String countryCode = 'US',
}) {
  return '''
{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "$merchantId",
    "displayName": "$merchantName",
    "countryCode": "$countryCode",
    "currencyCode": "$currencyCode",
    "supportedNetworks": ["visa", "masterCard", "amex", "discover"],
    "merchantCapabilities": ["debit", "credit", "3DS"]
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
    "countryCode": "US",
    "currencyCode": "USD",
    "supportedNetworks": ["visa", "masterCard", "amex", "discover"],
    "merchantCapabilities": ["debit", "credit", "3DS"]
  }
}
''';
