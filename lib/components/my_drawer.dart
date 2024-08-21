import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:payment_app/components/drawer_comp.dart';
import 'package:payment_app/localization/locals.dart';
import 'package:payment_app/pages/language_page.dart';
import 'package:payment_app/pages/payment_page.dart';
import 'package:payment_app/pages/settings.dart';
import 'package:payment_app/pages/sign_in_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void signOut(BuildContext context) async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
      );
    }

    return Drawer(
      backgroundColor: Colors.indigo,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  FluentIcons.settings_48_regular,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 60),
                DrawerComponents(
                  onTap: () => Navigator.pop(context),
                  text: LocalData.homepage.getString(context),
                  icon: FluentIcons.home_48_regular,
                ),
                const SizedBox(height: 20),
                DrawerComponents(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentPage()),
                  ),
                  text: LocalData.payments.getString(context),
                  icon: FluentIcons.payment_48_regular,
                ),
                const SizedBox(height: 20),
                DrawerComponents(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguagePage()),
                    );
                  },
                  text: LocalData.language.getString(context),
                  icon: FluentIcons.globe_48_regular,
                ),
                const SizedBox(height: 20),
                DrawerComponents(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                  text: LocalData.settings.getString(context),
                  icon: FluentIcons.settings_48_regular,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20),
            child: DrawerComponents(
              onTap: () => signOut(context),
              text: LocalData.logout.getString(context),
              icon: FluentIcons.sign_out_24_regular,
            ),
          ),
        ],
      ),
    );
  }
}
