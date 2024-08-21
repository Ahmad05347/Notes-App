import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildButton(BuildContext context, String text, Color bgColor,
    Color textColor, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.4,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bgColor,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

Widget buildRow(IconData title, bool isNotEmpty, String text) {
  return Row(
    children: [
      Icon(
        isNotEmpty ? Icons.check_box_outlined : Icons.check_box_outline_blank,
        color: isNotEmpty ? Colors.green : Colors.grey,
      ),
      Icon(
        title,
        size: 26,
      ),
      SizedBox(
        width: 10.w,
      ),
      Text(
        text,
        style: GoogleFonts.poppins(),
      )
    ],
  );
}

Widget reusableText(String text, bool isBold) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: 16,
    ),
  );
}
