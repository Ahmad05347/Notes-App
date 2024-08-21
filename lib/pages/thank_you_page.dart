import 'package:flutter/material.dart';
import 'package:payment_app/pages/notes_page.dart';

class ThankYouPage extends StatelessWidget {
  final bool isPaymentMade;

  const ThankYouPage({super.key, required this.isPaymentMade});

  @override
  Widget build(BuildContext context) {
    // Automatically navigate to the home page after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NotesPage(isPaymentMade: isPaymentMade),
        ),
        (Route<dynamic> route) => false,
      );
    });

    return const Scaffold(
      body: Center(
        child: Text(
          'Thank you for your payment!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
