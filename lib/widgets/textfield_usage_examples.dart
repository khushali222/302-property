import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_textfield.dart';

// This file contains usage examples for the CustomTextField widget
// You can reference these examples when implementing text fields in your forms

class TextFieldUsageExamples extends StatefulWidget {
  @override
  _TextFieldUsageExamplesState createState() => _TextFieldUsageExamplesState();
}

class _TextFieldUsageExamplesState extends State<TextFieldUsageExamples> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Error states
  bool nameError = false;
  bool emailError = false;
  bool phoneError = false;
  bool dateError = false;

  // Error messages
  String nameErrorMessage = '';
  String emailErrorMessage = '';
  String phoneErrorMessage = '';
  String dateErrorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomTextField Usage Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Basic text field with label and required indicator
            CustomTextField(
              controller: nameController,
              hintText: "Enter your name",
              labelText: "Full Name",
              hasError: nameError,
              errorMessage: nameErrorMessage,
              isRequired: true,
              onChanged: (value) {
                setState(() {
                  nameError = false;
                });
              },
            ),
            const SizedBox(height: 20),

            // Email field with validation
            CustomTextField(
              controller: emailController,
              hintText: "Enter your email",
              labelText: "Email Address",
              hasError: emailError,
              errorMessage: emailErrorMessage,
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  emailError = false;
                });
              },
            ),
            const SizedBox(height: 20),

            // Phone number field with formatter
            CustomTextField(
              controller: phoneController,
              hintText: "Enter phone number",
              labelText: "Phone Number",
              hasError: phoneError,
              errorMessage: phoneErrorMessage,
              isRequired: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                PhoneNumberFormatter(),
              ],
              onChanged: (value) {
                setState(() {
                  phoneError = false;
                });
              },
            ),
            const SizedBox(height: 20),

            // Date field
            CustomDateTextField(
              controller: dateController,
              hintText: "YYYY-MM-DD",
              labelText: "Birth Date",
              hasError: dateError,
              errorMessage: dateErrorMessage,
              isRequired: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),

            // Multi-line text field (for addresses, comments, etc.)
            CustomTextField(
              controller: addressController,
              hintText: "Enter your address",
              labelText: "Address",
              maxLines: 3,
              height: 80,
            ),
            const SizedBox(height: 20),

            // Password field
            CustomTextField(
              controller: passwordController,
              hintText: "Enter password",
              labelText: "Password",
              isRequired: true,
              // You can add obscureText functionality by extending the widget
            ),
            const SizedBox(height: 20),

            // Field without label (inline style)
            CustomTextField(
              controller: TextEditingController(),
              hintText: "Search...",
              showLabel: false,
              suffixIcon: const Icon(Icons.search),
              borderRadius: BorderRadius.circular(25),
            ),
            const SizedBox(height: 20),

            // Numeric field with specific formatting
            CustomTextField(
              controller: TextEditingController(),
              hintText: "0.00",
              labelText: "Amount",
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixText: "\$ ",
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
}

/* 
=== USAGE GUIDE ===

1. BASIC TEXT FIELD:
CustomTextField(
  controller: yourController,
  hintText: "Enter text",
  labelText: "Label",
  onChanged: (value) => setState(() => error = false),
)

2. REQUIRED FIELD WITH ERROR:
CustomTextField(
  controller: yourController,
  hintText: "Enter text",
  labelText: "Label",
  isRequired: true,
  hasError: errorState,
  errorMessage: errorMessage,
  onChanged: (value) => setState(() => errorState = false),
)

3. EMAIL FIELD:
CustomTextField(
  controller: emailController,
  hintText: "Enter email",
  labelText: "Email",
  keyboardType: TextInputType.emailAddress,
  isRequired: true,
)

4. PHONE NUMBER FIELD:
CustomTextField(
  controller: phoneController,
  hintText: "Enter phone",
  labelText: "Phone",
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
    PhoneNumberFormatter(),
  ],
)

5. DATE FIELD:
CustomDateTextField(
  controller: dateController,
  hintText: "YYYY-MM-DD",
  labelText: "Date",
  onTap: () => _selectDate(context),
)

6. MULTI-LINE FIELD:
CustomTextField(
  controller: addressController,
  hintText: "Enter address",
  labelText: "Address",
  maxLines: 3,
  height: 80,
)

7. SEARCH FIELD (NO LABEL):
CustomTextField(
  controller: searchController,
  hintText: "Search...",
  showLabel: false,
  suffixIcon: Icon(Icons.search),
  borderRadius: BorderRadius.circular(25),
)

8. CURRENCY FIELD:
CustomTextField(
  controller: amountController,
  hintText: "0.00",
  labelText: "Amount",
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  prefixText: "\$ ",
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ],
)

9. CUSTOM STYLING:
CustomTextField(
  controller: yourController,
  hintText: "Enter text",
  labelText: "Label",
  borderRadius: BorderRadius.circular(15),
  borderColor: Colors.blue,
  focusedBorderColor: Colors.green,
  errorBorderColor: Colors.red,
  elevation: 8,
)

10. ROW OF TEXT FIELDS:
Row(
  children: [
    Expanded(
      child: CustomTextField(
        controller: firstController,
        hintText: "First",
        labelText: "First Name",
      ),
    ),
    SizedBox(width: 10),
    Expanded(
      child: CustomTextField(
        controller: lastController,
        hintText: "Last",
        labelText: "Last Name",
      ),
    ),
  ],
)

=== BENEFITS ===
- Consistent styling across your app
- Built-in error handling
- Responsive design (adapts to screen size)
- Easy to maintain and update
- Reduces code duplication
- Configurable for different use cases
*/ 