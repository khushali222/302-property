# How Google Pay Works with NMI Payment Gateway in Flutter

## 📋 Overview

This document explains how Google Pay integration works in your Flutter app using the NMI (Network Merchants Inc.) payment gateway. The implementation uses the `pay` package for Flutter to handle Google Pay transactions.

---

## 🔄 Complete Payment Flow

### Step 1: Initialization
When the checkout screen loads, the app:

1. **Fetches NMI Credentials** (`_fetchNmiKeys()`)
   - Calls API: `GET /api/nmi-keys/nmi-keys/:admin_id`
   - Retrieves:
     - `merchant_id` - Your NMI merchant ID
     - `security_key` - Your NMI security key (used by backend)
     - `merchant_name` - Display name for payments

2. **Generates Payment Configuration** (`_generatePaymentConfigurations()`)
   - Creates a dynamic Google Pay configuration JSON
   - Includes:
     - Merchant ID from NMI
     - Payment amount
     - Supported card networks (VISA, MASTERCARD, AMEX, DISCOVER, JCB)
     - Tokenization settings for NMI gateway

3. **Checks Plugin Availability** (`_checkPayPluginAvailability()`)
   - Verifies the `pay` plugin is available
   - Ensures Google Pay SDK is accessible

---

### Step 2: User Interaction

1. **User Clicks Google Pay Button**
   - The `GooglePayButton` widget is rendered with the configuration
   - Button only appears if:
     - Plugin is available
     - Configuration is valid
     - Device supports Google Pay

2. **Google Pay Sheet Opens**
   - Google Pay SDK displays payment sheet
   - User selects a card (if multiple cards available)
   - User authorizes with fingerprint/Face ID/PIN

---

### Step 3: Token Generation (Google Pay Side)

**Important:** Token generation happens on **Google's servers**, NOT in your app!

1. **Google Pay SDK Processes Payment**
   - Validates card details
   - Checks card network compatibility
   - Generates encrypted payment token

2. **Token Types:**
   - **ECv2 (Encrypted Card v2)** - Preferred, supports 3D Secure
     - Works with NMI
     - Generated for real production cards
   - **ECv1 (Encrypted Card v1)** - Legacy format
     - May not work with NMI
     - Often generated for test cards

3. **Token Structure:**
   ```json
   {
     "paymentMethodData": {
       "tokenizationData": {
         "token": "{\"signature\":\"...\",\"intermediateSigningKey\":{...},\"protocolVersion\":\"ECv2\",\"signedMessage\":\"...\"}"
       },
       "type": "CARD",
       "description": "Visa ••••1234"
     }
   }
   ```

---

### Step 4: Token Receipt (Your App)

The `onGooglePayResult()` callback receives the token:

```dart
void onGooglePayResult(Map<String, dynamic> paymentResult) async {
  // Extract token from nested structure
  final token = paymentResult['paymentMethodData']['tokenizationData']['token'];
  
  // Send to your backend
  await sendPaymentTokenToServer(
    wallet: 'googlepay',
    paymentData: paymentResult,
    amount: widget.amount.toStringAsFixed(2),
  );
}
```

**Key Points:**
- Token is **encrypted** and **secure**
- Token contains **no actual card numbers**
- Token is **one-time use** (single transaction)
- Token is **time-limited** (expires after a few minutes)

---

### Step 5: Backend Processing

Your app sends the token to your backend API:

**Endpoint:** `POST /api/nmipayment/wallet-payment`

**Request Body:**
```json
{
  "paymentDetails": {
    "admin_id": "...",
    "lease_id": "...",
    "tenant_id": "...",
    "payment_token": "{\"signature\":\"...\",\"protocolVersion\":\"ECv2\",...}",
    "payment_method": "googlepay",
    "amount": "100.00",
    "processor_id": "...",
    "rentalAddress": "...",
    "entry": [...]
  }
}
```

**Backend Responsibilities:**
1. **Decrypts the token** using NMI's gateway services
2. **Extracts card details** (tokenized, not actual card numbers)
3. **Sends to NMI API** with:
   - Security key (authentication)
   - Merchant ID
   - Payment amount
   - Tokenized card data
4. **Processes payment** through NMI
5. **Returns response** to your app

---

### Step 6: Payment Response

**Success Response (statusCode: 100):**
```json
{
  "statusCode": 100,
  "data": {
    "transactionid": "123456789",
    "responsetext": "Transaction approved"
  }
}
```

**Your App:**
- Stores payment record in database
- Shows success message to user
- Returns to previous screen

**Error Response:**
- Handles various error types:
  - Network errors
  - Authentication errors
  - Payment declined
  - Server errors
- Shows appropriate error messages to user

---

## 🔧 Technical Implementation Details

### 1. Payment Configuration

The Google Pay configuration is generated dynamically:

```dart
_googlePayConfigString = generateGooglePayConfig(
  merchantId: _merchantId!,  // From NMI API
  amount: widget.amount.toStringAsFixed(2),
  merchantName: _merchantName ?? 'Cloud Rental Manager',
);
```

**Configuration Structure:**
```json
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST" | "PRODUCTION",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [{
      "type": "CARD",
      "parameters": {
        "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
        "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER", "JCB"]
      },
      "tokenizationSpecification": {
        "type": "PAYMENT_GATEWAY",
        "parameters": {
          "gateway": "gatewayservices",  // NMI's gateway identifier
          "gatewayMerchantId": "YOUR_NMI_MERCHANT_ID"
        }
      }
    }],
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "100.00",
      "currencyCode": "USD"
    }
  }
}
```

**Key Configuration Elements:**
- **gateway**: `"gatewayservices"` - This tells Google Pay to use NMI's gateway
- **gatewayMerchantId**: Your NMI merchant ID
- **environment**: `"TEST"` for development, `"PRODUCTION"` for live payments
- **allowedCardNetworks**: Which card types you accept

---

### 2. Token Extraction

The token is extracted from the nested structure:

```dart
if (wallet == 'googlepay' && paymentData.containsKey('paymentMethodData')) {
  final pmData = paymentData['paymentMethodData'] as Map<String, dynamic>?;
  if (pmData?.containsKey('tokenizationData') == true) {
    final tokenData = pmData!['tokenizationData'] as Map<String, dynamic>?;
    if (tokenData?.containsKey('token') == true) {
      final innerToken = tokenData!['token'] as String?;
      if (innerToken != null) {
        paymentTokenForNmi = innerToken;  // Send this to backend
      }
    }
  }
}
```

---

### 3. Error Handling

The implementation handles multiple error scenarios:

**Network Errors:**
- No internet connection
- Timeout (30 seconds)
- HTTP exceptions

**Authentication Errors:**
- Invalid/expired app token
- NMI security key authentication failure
- Missing credentials

**Payment Errors:**
- Card declined
- Insufficient funds
- Invalid card
- 3D Secure authentication failed

**Server Errors:**
- Backend API errors (500+)
- Invalid response format
- Service unavailable

---

## 🔐 Security Features

1. **Token Encryption**
   - Tokens are encrypted by Google Pay
   - Never contain actual card numbers
   - One-time use only

2. **Secure Transmission**
   - HTTPS for all API calls
   - Authentication headers required
   - Token sent directly to backend (not stored)

3. **PCI Compliance**
   - Your app never handles raw card data
   - All card processing handled by Google Pay and NMI
   - Reduces PCI compliance scope

---

## 📱 Platform Requirements

### Android
- Google Play Services installed
- Google Pay app installed (or built-in)
- At least one card added to Google Pay
- Device supports NFC (for in-store payments)

### iOS
- iOS 11.0+
- Apple Pay configured in device settings
- Card added to Apple Wallet
- Proper app signing with merchant identifier

---

## 🧪 Testing

### Test Environment
- Set `PAYMENT_ENVIRONMENT = 'TEST'` in `payment_configurations.dart`
- Works without Google Pay Console registration
- Test cards may generate ECv1 tokens (may not work with NMI)

### Production Environment
- Set `PAYMENT_ENVIRONMENT = 'PRODUCTION'`
- Requires Google Pay Console merchant registration
- Real cards generate ECv2 tokens (compatible with NMI)

### Test Cards
- Test cards often generate ECv1 tokens
- NMI may reject ECv1 tokens
- Use real production cards for full testing

---

## 🔄 Data Flow Diagram

```
┌─────────────┐
│   User      │
│  (Flutter)  │
└──────┬──────┘
       │
       │ 1. Clicks Google Pay Button
       ▼
┌─────────────────────┐
│  Google Pay SDK     │
│  (Payment Sheet)    │
└──────┬──────────────┘
       │
       │ 2. User Authorizes Payment
       ▼
┌─────────────────────┐
│  Google Pay Servers │
│  (Token Generation) │
└──────┬──────────────┘
       │
       │ 3. Returns Encrypted Token
       ▼
┌─────────────────────┐
│  Flutter App        │
│  (onGooglePayResult)│
└──────┬──────────────┘
       │
       │ 4. Sends Token to Backend
       ▼
┌─────────────────────┐
│  Your Backend API   │
│  (/wallet-payment)  │
└──────┬──────────────┘
       │
       │ 5. Decrypts Token & Sends to NMI
       ▼
┌─────────────────────┐
│  NMI Payment Gateway│
│  (Processes Payment)│
└──────┬──────────────┘
       │
       │ 6. Returns Transaction Result
       ▼
┌─────────────────────┐
│  Your Backend API   │
│  (Returns Response) │
└──────┬──────────────┘
       │
       │ 7. Shows Success/Error
       ▼
┌─────────────────────┐
│  Flutter App        │
│  (User Sees Result) │
└─────────────────────┘
```

---

## 📝 Key Files

1. **`checkout_screen.dart`**
   - Main checkout UI
   - Google Pay button rendering
   - Payment result handling
   - Error management

2. **`payment_configurations.dart`**
   - Google Pay configuration generation
   - Environment settings (TEST/PRODUCTION)
   - Payment method definitions

3. **`nmi_keys_service.dart`**
   - Fetches NMI credentials from API
   - Handles authentication
   - Returns merchant ID and security key

---

## ⚠️ Important Notes

1. **Merchant ID vs Security Key**
   - **Merchant ID**: Used in Google Pay configuration (frontend)
   - **Security Key**: Used by backend for NMI API authentication (never sent to frontend)

2. **Token Format**
   - Tokens are JSON strings (double-encoded)
   - Backend must parse and decrypt properly
   - Token format varies (ECv1 vs ECv2)

3. **Environment Settings**
   - TEST mode: Works without Google Pay Console setup
   - PRODUCTION mode: Requires merchant registration
   - Environment affects token generation

4. **Error Handling**
   - Always handle network failures gracefully
   - Show user-friendly error messages
   - Log detailed errors for debugging

---

## 🎯 Summary

**How it works in simple terms:**

1. User clicks Google Pay button
2. Google Pay shows payment sheet
3. User authorizes with biometric/PIN
4. Google generates encrypted token
5. Your app receives token
6. App sends token to your backend
7. Backend decrypts token and sends to NMI
8. NMI processes payment
9. Backend returns result to app
10. App shows success/error to user

**Key Security Points:**
- ✅ No card numbers stored in app
- ✅ Tokens are encrypted
- ✅ One-time use tokens
- ✅ Secure HTTPS transmission
- ✅ PCI compliance maintained

---

## 🔗 Related Documentation

- [Google Pay API Documentation](https://developers.google.com/pay/api)
- [NMI Payment Gateway Documentation](https://secure.networkmerchants.com/gw/merchants/resources/integration/integration_portal.php)
- [Flutter Pay Package](https://pub.dev/packages/pay)

---

## 📞 Support

If you encounter issues:

1. Check logs for detailed error messages
2. Verify NMI credentials are correct
3. Ensure Google Pay is properly set up on device
4. Check network connectivity
5. Verify backend API is accessible
6. Review token format in logs

---

**Last Updated:** Based on current codebase implementation
**Version:** 1.0

