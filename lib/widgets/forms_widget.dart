import 'package:flutter/material.dart';

class FormWidget extends StatefulWidget {
  final double? fontSize;
  final int? maxLines;
  final TextEditingController controller;
  final String hintText;
  final bool? isBorder;
  final int maxLength;
  final bool? isIcon;
  final VoidCallback? onAdd;

  const FormWidget({
    super.key,
    this.fontSize,
    this.maxLines,
    required this.controller,
    required this.hintText,
    this.isBorder,
    required this.maxLength,
    this.isIcon,
    this.onAdd,
  });

  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTapOutside(BuildContext context) {
    if (!_focusNode.hasFocus) return;
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTapOutside(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            TextFormField(
              focusNode: _focusNode,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              style: TextStyle(fontSize: widget.fontSize),
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              keyboardType: TextInputType.multiline,
              onEditingComplete: () {
                _focusNode.unfocus();
              },
            ),
            if (widget.isIcon == true)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    size: 35,
                    Icons.add_circle,
                    color: Colors.indigoAccent,
                  ),
                  onPressed: widget.onAdd,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
