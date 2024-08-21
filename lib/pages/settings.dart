import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSwitched3 = true;
  bool isSwitched6 = false;
  bool isSwitched10 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "3 Pages",
                  style: GoogleFonts.poppins(),
                ),
                Switch(
                  value: isSwitched3,
                  onChanged: (value) {
                    setState(() {
                      isSwitched3 = value;
                      if (value) {
                        isSwitched6 = false;
                        isSwitched10 = false;
                      }
                    });
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "6 Pages",
                  style: GoogleFonts.poppins(),
                ),
                Switch(
                  value: isSwitched6,
                  onChanged: (value) {
                    setState(() {
                      isSwitched6 = value;
                      if (value) {
                        isSwitched3 = false;
                        isSwitched10 = false;
                      }
                    });
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "10 Pages",
                  style: GoogleFonts.poppins(),
                ),
                Switch(
                  value: isSwitched10,
                  onChanged: (value) {
                    setState(() {
                      isSwitched10 = value;
                      if (value) {
                        isSwitched3 = false;
                        isSwitched6 = false;
                      }
                    });
                  },
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                int numberOfComponents;
                if (isSwitched3) {
                  numberOfComponents = 3;
                } else if (isSwitched6) {
                  numberOfComponents = 6;
                } else {
                  numberOfComponents = 10;
                }
                /* Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesPage(
                      numberOfComponents: numberOfComponents,
                    ),
                  ),
                );*/
              },
              child: const Text('Save and Go to Notes'),
            ),
          ],
        ),
      ),
    );
  }
}
