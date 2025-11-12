// lib/payment_configurations.dart (Test Configuration)

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
      "totalPrice": "19.99",
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
