import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taski/main.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key, 
    required this.controller, 
    required this.hintText, 
    required this.isDark, 
    required this.validator, 
    this.keyboardType = TextInputType.text,
    this.inputFormatters
  });

  final TextEditingController controller;
  final String hintText;
  final bool isDark;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 18),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        hintStyle: TextStyle(
          fontSize: config.sp(14),
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade400
        ),
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),  
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    );
  }
}