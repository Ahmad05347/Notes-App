import 'package:flutter/material.dart';

class NotesWidget extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final IconData icon;
  const NotesWidget({
    super.key,
    required this.text,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20,
        top: 10,
      ),
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        width: MediaQuery.of(context).size.width,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  icon,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
