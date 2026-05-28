import 'package:flutter/material.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/styles/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceTypingPage extends StatefulWidget {
  final Function(String) onResult;

  const VoiceTypingPage({super.key, required this.onResult});

  @override
  _VoiceTypingPageState createState() => _VoiceTypingPageState();
}

class _VoiceTypingPageState extends State<VoiceTypingPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  String _lastRecognizedText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => setState(() {
        _isListening = _speech.isListening;
      }),
      onError: (val) => setState(() {
        _isListening = false;
      }),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => _onSpeechResult(val.recognizedWords),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _onSpeechResult(String recognizedWords) {
    // Check if the recognizedWords is already at the end of the _lastRecognizedText
    if (!_lastRecognizedText.endsWith(recognizedWords)) {
      setState(() {
        _text = '$_lastRecognizedText $recognizedWords';
        _lastRecognizedText = _text.trim();
        widget.onResult(_text.trim());
      });
    }
  }

  Future<bool> onBackPress({void Function()? callback}) async {
    return await ShowInterstitialAds()
        .showBackClickInterstitialAds(callback: callback);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPress(
        callback: () => Navigator.pop(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace:
              NotebookAppBarDecoration.flexibleSpaceForTheme(context),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text('Voice Typing'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _text,
                style: const TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                tooltip: 'Listen',
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
