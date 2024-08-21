import 'package:flutter/material.dart';

class PhotosComponents extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  final Function(LongPressEndDetails)? onLongPressEnd;
  const PhotosComponents({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onPressed,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        margin: const EdgeInsets.all(
          10,
        ),
        padding: const EdgeInsets.all(
          10,
        ),
        width: 200,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.grey.shade400,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
