import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Shared form building blocks for the Team & Access "Add" screens
// (Add Admin / Add Staff) so both stay visually consistent.

const Color _navy = Color(0xFF152B51); // == blueColor RGBO(21,43,81,1)
const Color _fieldBorder = Color(0xFFCED4DA);
const Color _hint = Color(0xFFA1A8B0);

Widget teamBackRow(BuildContext context, {String label = 'Team & Access'}) {
  return InkWell(
    onTap: () => Navigator.of(context).maybePop(),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_left, color: _navy, size: 22),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget teamBanner(String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: _navy,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.35),
          offset: const Offset(0, 1),
          blurRadius: 6,
        ),
      ],
    ),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget teamFieldLabel(String label, {bool required = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF101828),
        ),
        children: required
            ? const [
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ]
            : const [],
      ),
    ),
  );
}

Widget teamTextField(
  TextEditingController controller,
  String hint, {
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  VoidCallback? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _fieldBorder),
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      cursorColor: _navy,
      style: const TextStyle(color: _navy, fontSize: 15),
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _hint, fontSize: 14),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      ),
    ),
  );
}

Widget teamErrorText(String msg) {
  return Padding(
    padding: const EdgeInsets.only(top: 5, left: 3),
    child: Text(
      msg,
      style: const TextStyle(color: Colors.red, fontSize: 12.5),
    ),
  );
}

Widget teamButtons({
  required VoidCallback onCancel,
  required VoidCallback onPrimary,
  required String primaryLabel,
  required IconData primaryIcon,
  required bool loading,
}) {
  return Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: loading ? null : onCancel,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x80152B51)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _navy,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: GestureDetector(
          onTap: loading ? null : onPrimary,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: loading
                ? const SpinKitFadingCircle(color: Colors.white, size: 24)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(primaryIcon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        primaryLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ],
  );
}
