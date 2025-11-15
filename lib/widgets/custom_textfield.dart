import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constant/constant.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool hasError;
  final String errorMessage;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final double? height;
  final double? width;
  final bool isRequired;
  final bool showLabel;
  final double elevation;
  final EdgeInsets? contentPadding;
  final int? maxLines;
  final String? prefixText;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final bool isInRow;
  final bool showElevation;
  final bool obscureText;
  final bool showErrorInTooltip;
  final String? Function(String?)? validator;
  final bool wrapErrorText;
  final int errorMaxLines;
  final TextStyle? errorTextStyle;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.hasError = false,
    this.errorMessage = '',
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.height,
    this.width,
    this.isRequired = false,
    this.showLabel = true,
    this.elevation = 4,
    this.contentPadding,
    this.maxLines = 1,
    this.prefixText,
    this.hintStyle,
    this.labelStyle,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.isInRow = false,
    this.showElevation = true,
    this.obscureText = false,
    this.showErrorInTooltip = false,
    this.validator,
    this.wrapErrorText = true,
    this.errorMaxLines = 2,
    this.errorTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formField = Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        obscureText: obscureText,
        cursorColor: blueColor,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          prefixText: prefixText,
          hintStyle: hintStyle ??
              TextStyle(
                fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 19,
                color: Color(0xFF8A95A8),
              ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          contentPadding: contentPadding ??
              EdgeInsets.all(MediaQuery.of(context).size.width < 500 ? 14 : 11),
          suffixIcon: suffixIcon,
          errorText: null, // Always null to prevent showing errors inside field
        ),
      ),
    );

    Widget textFieldWidget = Material(
      elevation: showElevation ? elevation : 0,
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: Container(
        width: width,
        constraints: height != null ? BoxConstraints(minHeight: height!) : null,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          border: Border.all(
            color: hasError
                ? (errorBorderColor ?? Colors.red.shade300)
                : (borderColor ?? Color(0xFF8A95A8)),
            width: 1,
          ),
        ),
        child: formField,
      ),
    );

    // If showing error in tooltip, wrap the textfield in a tooltip
    if (showErrorInTooltip && hasError && errorMessage.isNotEmpty) {
      textFieldWidget = MouseRegion(
        cursor: SystemMouseCursors.help,
        child: Tooltip(
          message: errorMessage,
          preferBelow: true,
          showDuration: const Duration(seconds: 3),
          waitDuration: const Duration(milliseconds: 500),
          triggerMode: TooltipTriggerMode.tap,
          decoration: BoxDecoration(
            color: errorBorderColor?.withOpacity(0.9) ?? Colors.red[700],
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textStyle: errorTextStyle?.copyWith(color: Colors.white) ??
              TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: textFieldWidget,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (showLabel && labelText != null) ...[
          Row(
            children: [
              Text(
                labelText!,
                style: labelStyle ??
                    TextStyle(
                      color: Color(0xFF8A95A8),
                      fontWeight: FontWeight.bold,
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 15 : 20,
                    ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 20,
                  ),
                ),
            ],
          ),
          SizedBox(height: 5),
        ],

        // Text Field with optional tooltip
        textFieldWidget,

        // Error Message (only shown if not using tooltip)
        if (!showErrorInTooltip && hasError && errorMessage.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.only(
              top: 4,
              left: isInRow ? 0 : 4,
              right: isInRow ? 0 : 4,
            ),
            constraints: BoxConstraints(
              minHeight: 20,
              maxWidth: isInRow && wrapErrorText
                  ? width ?? double.infinity
                  : double.infinity,
            ),
            child: Text(
              errorMessage,
              style: errorTextStyle ??
                  TextStyle(
                    color: errorBorderColor ?? Colors.red.shade700,
                    fontSize: 12,
                  ),
              maxLines: wrapErrorText ? errorMaxLines : 1,
              overflow:
                  wrapErrorText ? TextOverflow.ellipsis : TextOverflow.clip,
            ),
          ),
        ],
      ],
    );
  }
}

// Phone Number Formatter (if not already exists)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length <= 3) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 6) {
      return newValue.copyWith(
        text: '${text.substring(0, 3)}-${text.substring(3)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else if (text.length <= 10) {
      return newValue.copyWith(
        text:
            '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    } else {
      return oldValue;
    }
  }
}

// Date TextField Widget (for date selection)
class CustomDateTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool hasError;
  final String errorMessage;
  final VoidCallback onTap;
  final bool isRequired;
  final double? height;
  final double? width;

  const CustomDateTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onTap,
    this.labelText,
    this.hasError = false,
    this.errorMessage = '',
    this.isRequired = false,
    this.height = 50,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      labelText: labelText,
      hasError: hasError,
      errorMessage: errorMessage,
      readOnly: true,
      onTap: onTap,
      isRequired: isRequired,
      height: height,
      width: width,
      suffixIcon: IconButton(
        icon: Icon(Icons.calendar_today),
        onPressed: onTap,
      ),
    );
  }
}

class CustomInfoCard extends StatelessWidget {
  final String title;
  final List<InfoRow> rows;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const CustomInfoCard({
    Key? key,
    required this.title,
    required this.rows,
    this.padding,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            ...rows.map((row) => _buildInfoRow(row)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(InfoRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.value.isEmpty ? 'N/A' : row.value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: row.value.isEmpty
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow {
  final String label;
  final String value;

  InfoRow(this.label, this.value);
}

class CustomSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomSectionHeader({
    Key? key,
    required this.title,
    this.margin,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor ?? blueColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isOutlined;

  const CustomActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined ? Colors.white : (backgroundColor ?? blueColor),
          foregroundColor: isOutlined
              ? (backgroundColor ?? blueColor)
              : (textColor ?? Colors.white),
          elevation: isOutlined ? 0 : 2,
          side: isOutlined
              ? BorderSide(color: backgroundColor ?? blueColor, width: 1.5)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CustomCardTransactionSettings extends StatelessWidget {
  final bool creditCardAccepted;
  final bool debitCardAccepted;
  final String title;
  final String subtitle;

  const CustomCardTransactionSettings({
    Key? key,
    required this.creditCardAccepted,
    required this.debitCardAccepted,
    this.title = "Card Transaction Type Settings",
    this.subtitle = "Allowed card types for rental transactions",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            _buildCardOption("Credit Card", creditCardAccepted),
            const SizedBox(height: 12),
            _buildCardOption("Debit Card", debitCardAccepted),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOption(String cardType, bool isAccepted) {
    return Row(
      children: [
        Icon(
          isAccepted ? Icons.check_circle : Icons.cancel,
          color: isAccepted ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          cardType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class CustomAppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onEditPressed;
  final VoidCallback? onBackPressed;
  final bool showEdit;
  final bool showBack;

  const CustomAppHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onEditPressed,
    this.onBackPressed,
    this.showEdit = true,
    this.showBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 24,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 15),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (showEdit) ...[
            CustomActionButton(
              text: "Edit",
              onPressed: onEditPressed ?? () {},
              width: 80,
              height: 40,
            ),
          ],
        ],
      ),
    );
  }
}

// Helper function for phone number formatting
String formatPhoneNumber(String phoneNumber) {
  if (phoneNumber.isEmpty || phoneNumber == 'null') return 'N/A';

  // Remove all non-digit characters
  String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

  if (digitsOnly.length == 10) {
    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
    return '+1 ${digitsOnly.substring(1, 4)}-${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
  }

  return phoneNumber;
}
