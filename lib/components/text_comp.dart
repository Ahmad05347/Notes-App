import 'package:flutter/material.dart';

class TextComponent extends StatelessWidget {
  final String text;

  const TextComponent({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.grey.shade600,
          ),
        ),
        child: Center(
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
