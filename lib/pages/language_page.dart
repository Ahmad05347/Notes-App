import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payment_app/components/my_button.dart';
import 'package:payment_app/localization/locals.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale;

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          LocalData.title.getString(context),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                _buildLanguageOption(
                  context,
                  'English',
                  'en',
                ),
                const Divider(),
                _buildLanguageOption(
                  context,
                  'عربي',
                  'ar',
                ),
              ],
            ),
            myButton(
              "Save",
              Colors.indigo,
              () {
                Navigator.pop(context);
              },
              Colors.white,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String language, String locale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          language,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Checkbox(
          value: _currentLocale == locale,
          onChanged: (value) {
            if (value == true) {
              _setLocale(locale);
            }
          },
        ),
      ],
    );
  }

  void _setLocale(String value) {
    _flutterLocalization.translate(value);
    setState(() {
      _currentLocale = value;
    });
  }
}
