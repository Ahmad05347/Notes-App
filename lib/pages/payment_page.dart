import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:payment_app/pages/thank_you_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isPaymentMade = false;
  String selectedPlan = 'Free Plan';

  Future<void> initPaymentSheet(String amount) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51H3yqVJNwV2vxLP6IweKuPqI2USH4eqp9Nnma5YADpFJ7gqmKjsfsT4DZCkp56tos428s1S0UuAjECeNkdPKD2qJ00wJRHKfho',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': amount,
          'currency': 'usd',
          'payment_method_types[]': 'card'
        },
      );

      final paymentIntent = jsonDecode(response.body);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Example Merchant',
        ),
      );

      setState(() {});
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );

      setState(() {
        isPaymentMade = true;
      });

      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => ThankYouPage(
            isPaymentMade: isPaymentMade,
          ),
        ),
      );
    } catch (e) {
      if (e is StripeException) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void selectPlan(String plan, String amount) async {
    setState(() {
      selectedPlan = plan;
    });

    if (plan != 'Free Plan') {
      await initPaymentSheet(amount);
      await presentPaymentSheet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have selected the Free Plan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Choose Your Plan",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubscriptionOption(
              title: "Free Plan",
              description: const [
                "Create up to 10 notes",
                "2 images per note",
                "No videos",
                "No voice notes",
                "Text with voice note disabled",
                "Location not included"
              ],
              price: "Free",
              onSelect: () => selectPlan('Free Plan', '0'),
              isSelected: selectedPlan == 'Free Plan',
            ),
            const SizedBox(height: 20),
            SubscriptionOption(
              title: "Basic Plan",
              description: const [
                "Create up to 25 notes",
                "5 images per note",
                "5 videos",
                "5 voice notes",
                "Text with voice note enabled",
                "Get location with every note"
              ],
              price: "\$9.99 / month",
              onSelect: () => selectPlan('Basic Plan', '999'),
              isSelected: selectedPlan == 'Basic Plan',
            ),
            const SizedBox(height: 20),
            SubscriptionOption(
              title: "Premium Plan",
              description: const [
                "Create up to 50 notes",
                "10 images per note",
                "10 videos",
                "10 voice notes",
                "Text with voice note enabled",
                "Get location with every note"
              ],
              price: "\$24.99 / month",
              onSelect: () => selectPlan('Premium Plan', '2499'),
              isSelected: selectedPlan == 'Premium Plan',
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  final String title;
  final List<String> description;
  final String price;
  final VoidCallback onSelect;
  final bool isSelected;

  const SubscriptionOption({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.onSelect,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isSelected ? 1.0 : 0.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.indigoAccent : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.saira(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            ...description.map((desc) => Text(
                  desc,
                  style: GoogleFonts.saira(
                    color: isSelected ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                )),
            const SizedBox(height: 20),
            Text(
              price,
              style: GoogleFonts.saira(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  foregroundColor: isSelected ? Colors.indigo : Colors.white,
                  backgroundColor: isSelected ? Colors.white : Colors.indigo,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  isSelected ? "Selected" : "Select",
                  style: GoogleFonts.saira(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.indigo : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
