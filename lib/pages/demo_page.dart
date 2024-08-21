/* import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final SpeechToText speechToText = SpeechToText();

  bool speechEnabled = false;
  String wordsSpoken = "";
  double confidenceLevel = 0.0;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  void startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {
      wordsSpoken = ""; // Clear previous text
      confidenceLevel = 0.0;
    });
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      wordsSpoken = result.recognizedWords;
      confidenceLevel = result.confidence;
    });
  }

  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Mic"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                speechToText.isListening
                    ? "Listening..."
                    : speechEnabled
                        ? "Tap the mic to start listening"
                        : "Speech recognition not available",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  // Center the text within the Expanded widget
                  child: Text(
                    wordsSpoken,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize:
                            24), // Increase font size for better visibility
                  ),
                ),
              ),
            ),
            if (!speechToText.isListening && confidenceLevel > 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Confidence: ${(confidenceLevel * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: speechToText.isListening ? stopListening : startListening,
        tooltip: "Listen",
        child: Icon(
          speechToText.isListening
              ? FluentIcons.pause_circle_24_regular
              : FluentIcons.play_circle_24_regular,
          size: 30,
          color: speechEnabled ? Colors.green : Colors.grey.shade400,
        ),
      ),
    );
  }
}
*/
