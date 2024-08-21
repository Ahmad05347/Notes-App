import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesComp extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const CategoriesComp({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(
          10,
        ),
        padding: const EdgeInsets.all(
          10,
        ),
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade800,
            width: 0.35,
          ),
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
