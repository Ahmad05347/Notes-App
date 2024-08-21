import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget myButton(String text, Color color, void Function()? onTap,
    Color textColor, bool isWidth) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: isWidth ? 130 : 250,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
