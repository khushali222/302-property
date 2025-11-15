// lib/payment_configurations.dart (Test Configuration)
//
// NOTE: These configurations are set up for TEST/SANDBOX environment
// For production, update the environment and merchant credentials accordingly

// Google Pay Test Configuration
// Environment is set to "TEST" for sandbox testing
// Change to "PRODUCTION" when ready for live payments
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
            "gateway": "example",
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

// Apple Pay Test Configuration
// NOTE: Apple Pay uses sandbox mode automatically when:
// 1. Testing on a device with test Apple ID
// 2. Using a sandbox merchant identifier
// 3. Running in Xcode with sandbox environment
// For production, ensure you have a valid production merchant identifier
// and proper Apple Pay certificates configured in your Apple Developer account
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
