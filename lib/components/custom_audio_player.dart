import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class CustomAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String textContent;
  final String googleCloudApiKey; // Add your API key here

  const CustomAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.textContent,
    required this.googleCloudApiKey,
  });

  @override
  _CustomAudioPlayerState createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  String _transcription = '';
  bool _isTranscribing = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  Future<String> _transcribeAudio(String audioUri, String apiKey) async {
    final response = await http.post(
      Uri.parse(
          'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        "config": {
          "encoding": "LINEAR16", // Adjust to match your audio format
          "sampleRateHertz": 16000, // Adjust based on your audio sample rate
          "languageCode": "en-US",
        },
        "audio": {
          "uri": audioUri,
        }
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['results'][0]['alternatives'][0]['transcript'] ?? '';
    } else {
      throw Exception('Failed to transcribe audio');
    }
  }

  void _startTranscription() async {
    setState(() {
      _isTranscribing = true;
    });

    try {
      final transcription = await _transcribeAudio(
        widget.audioUrl,
        widget.googleCloudApiKey,
      );
      setState(() {
        _transcription = transcription;
      });
    } catch (e) {
      print("Error during transcription: $e");
    }

    setState(() {
      _isTranscribing = false;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _player.pause();
      } else {
        _player.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.indigoAccent,
                  size: 30,
                ),
                onPressed: _togglePlayPause,
              ),
              Text(
                _isPlaying ? 'Playing' : 'Paused',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Audio Content',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            widget.textContent,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          _isTranscribing
              ? const CircularProgressIndicator()
              : Text(
                  _transcription.isNotEmpty
                      ? _transcription
                      : 'Transcription will appear here.',
                  style: const TextStyle(fontSize: 16, color: Colors.indigoAccent),
                ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: _startTranscription,
                child: const Text('Start Transcription'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
