import 'package:flutter/material.dart';
import 'package:payment_app/widgets/colors.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String textType;
  final String hintText;
  final IconData iconName;
  final void Function(String value)? function;
  final String? Function(String?)? validator;

  const MyTextField({
    super.key,
    required this.textType,
    required this.hintText,
    required this.iconName,
    this.function,
    this.validator,
    required this.controller,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        onChanged: function,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          icon: Icon(
            iconName,
            color: AppColors.primaryElement,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: AppColors.primaryText,
          fontFamily: "Avenir",
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
