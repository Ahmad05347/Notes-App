import 'package:flutter/material.dart';

class VoiceMessageView extends StatelessWidget {
  final Color circlesColor;
  final Color activeSliderColor;
  final Color backgroundColor;
  final VoiceController controller;
  final double innerPadding;
  final double cornerRadius;

  const VoiceMessageView({
    super.key,
    required this.circlesColor,
    required this.activeSliderColor,
    required this.backgroundColor,
    required this.controller,
    required this.innerPadding,
    required this.cornerRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class VoiceController {
  final String audioSrc;
  final Duration maxDuration;
  final bool isFile;
  final VoidCallback onComplete;
  final VoidCallback onPause;
  final VoidCallback onPlaying;
  final void Function(String) onError;

  VoiceController({
    required this.audioSrc,
    required this.maxDuration,
    required this.isFile,
    required this.onComplete,
    required this.onPause,
    required this.onPlaying,
    required this.onError,
  });
}
