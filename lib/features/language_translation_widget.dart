import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:translator/translator.dart'; // hypothetical translation package
import '../models/model_note.dart'; // Import the Note model

class LanguageTranslationWidget extends StatefulWidget {
  final Function(String, {Note? note}) onTranslationComplete;
  final Note? note; // Optional note parameter

  const LanguageTranslationWidget(
      {super.key, required this.onTranslationComplete, this.note});

  @override
  _LanguageTranslationWidgetState createState() =>
      _LanguageTranslationWidgetState();
}

class _LanguageTranslationWidgetState extends State<LanguageTranslationWidget> {
  final TextEditingController _textController = TextEditingController();
  String? _sourceLanguage;
  String? _targetLanguage;
  final List<Map<String, String>> _languages = [
    {'code': 'auto', 'name': 'Auto Detect'},
    {'code': 'bn', 'name': 'Bangla'},
    {'code': 'af', 'name': 'Afrikaans'},
    {'code': 'sq', 'name': 'Albanian'},
    {'code': 'am', 'name': 'Amharic'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'hy', 'name': 'Armenian'},
    {'code': 'az', 'name': 'Azerbaijani'},
    {'code': 'eu', 'name': 'Basque'},
    {'code': 'be', 'name': 'Belarusian'},
    {'code': 'bs', 'name': 'Bosnian'},
    {'code': 'bg', 'name': 'Bulgarian'},
    {'code': 'ca', 'name': 'Catalan'},
    {'code': 'ceb', 'name': 'Cebuano'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'co', 'name': 'Corsican'},
    {'code': 'hr', 'name': 'Croatian'},
    {'code': 'cs', 'name': 'Czech'},
    {'code': 'da', 'name': 'Danish'},
    {'code': 'nl', 'name': 'Dutch'},
    {'code': 'en', 'name': 'English'},
    {'code': 'eo', 'name': 'Esperanto'},
    {'code': 'et', 'name': 'Estonian'},
    {'code': 'fi', 'name': 'Finnish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'fy', 'name': 'Frisian'},
    {'code': 'gl', 'name': 'Galician'},
    {'code': 'ka', 'name': 'Georgian'},
    {'code': 'de', 'name': 'German'},
    {'code': 'el', 'name': 'Greek'},
    {'code': 'gu', 'name': 'Gujarati'},
    {'code': 'ha', 'name': 'Hausa'},
    {'code': 'haw', 'name': 'Hawaiian'},
    {'code': 'he', 'name': 'Hebrew'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'hmn', 'name': 'Hmong'},
    {'code': 'hu', 'name': 'Hungarian'},
    {'code': 'is', 'name': 'Icelandic'},
    {'code': 'ig', 'name': 'Igbo'},
    {'code': 'id', 'name': 'Indonesian'},
    {'code': 'ga', 'name': 'Irish'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'jv', 'name': 'Javanese'},
    {'code': 'kn', 'name': 'Kannada'},
    {'code': 'kk', 'name': 'Kazakh'},
    {'code': 'km', 'name': 'Khmer'},
    {'code': 'rw', 'name': 'Kinyarwanda'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'ku', 'name': 'Kurdish'},
    {'code': 'ky', 'name': 'Kyrgyz'},
    {'code': 'lo', 'name': 'Lao'},
    {'code': 'la', 'name': 'Latin'},
    {'code': 'lv', 'name': 'Latvian'},
    {'code': 'lt', 'name': 'Lithuanian'},
    {'code': 'mk', 'name': 'Macedonian'},
    {'code': 'mg', 'name': 'Malagasy'},
    {'code': 'ms', 'name': 'Malay'},
    {'code': 'ml', 'name': 'Malayalam'},
    {'code': 'mt', 'name': 'Maltese'},
    {'code': 'mi', 'name': 'Maori'},
    {'code': 'mr', 'name': 'Marathi'},
    {'code': 'mn', 'name': 'Mongolian'},
    {'code': 'my', 'name': 'Myanmar'},
    {'code': 'ne', 'name': 'Nepali'},
    {'code': 'no', 'name': 'Norwegian'},
    {'code': 'ny', 'name': 'Nyanja'},
    {'code': 'or', 'name': 'Odia'},
    {'code': 'ps', 'name': 'Pashto'},
    {'code': 'fa', 'name': 'Persian'},
    {'code': 'pl', 'name': 'Polish'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'pa', 'name': 'Punjabi'},
    {'code': 'ro', 'name': 'Romanian'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'sm', 'name': 'Samoan'},
    {'code': 'sr', 'name': 'Serbian'},
    {'code': 'st', 'name': 'Sesotho'},
    {'code': 'sn', 'name': 'Shona'},
    {'code': 'sd', 'name': 'Sindhi'},
    {'code': 'si', 'name': 'Sinhala'},
    {'code': 'sk', 'name': 'Slovak'},
    {'code': 'sl', 'name': 'Slovenian'},
    {'code': 'so', 'name': 'Somali'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'su', 'name': 'Sundanese'},
    {'code': 'sw', 'name': 'Swahili'},
    {'code': 'sv', 'name': 'Swedish'},
    {'code': 'tl', 'name': 'Tagalog'},
    {'code': 'tg', 'name': 'Tajik'},
    {'code': 'ta', 'name': 'Tamil'},
    {'code': 'tt', 'name': 'Tatar'},
    {'code': 'te', 'name': 'Telugu'},
    {'code': 'th', 'name': 'Thai'},
    {'code': 'tr', 'name': 'Turkish'},
    {'code': 'tk', 'name': 'Turkmen'},
    {'code': 'uk', 'name': 'Ukrainian'},
    {'code': 'ur', 'name': 'Urdu'},
    {'code': 'ug', 'name': 'Uyghur'},
    {'code': 'uz', 'name': 'Uzbek'},
    {'code': 'cy', 'name': 'Welsh'},
    {'code': 'xh', 'name': 'Xhosa'},
    {'code': 'yi', 'name': 'Yiddish'},
    {'code': 'yo', 'name': 'Yoruba'},
    {'code': 'zu', 'name': 'Zulu'}
    // Add all other languages here
  ];
  final ImagePicker _picker = ImagePicker();

  void _translateText() async {
    if (_targetLanguage == null || _textController.text.isEmpty) {
      return;
    }

    ShowInterstitialAds().showClickInterstitialAds(callback: () async {
      final translator = GoogleTranslator(); // hypothetical API
      final translation = await translator.translate(
        _textController.text,
        from: _sourceLanguage ?? 'auto',
        to: _targetLanguage!,
      );
      widget.onTranslationComplete(translation.text, note: widget.note);
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _scanTextFromImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      final inputImage = InputImage.fromFile(image);
      final textDetector = TextRecognizer();

      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);

      String recognizedTextString = recognizedText.text;

      setState(() {
        _textController.text = recognizedTextString;
      });

      textDetector.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                DropdownButton<String>(
                  hint: const Text('From'),
                  value: _sourceLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sourceLanguage = newValue;
                    });
                  },
                  items: _languages.map((Map<String, String> language) {
                    return DropdownMenuItem<String>(
                      value: language['code'],
                      child: Text(language['name']!),
                    );
                  }).toList(),
                ),
                const Spacer(),
                DropdownButton<String>(
                  hint: const Text('To'),
                  value: _targetLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _targetLanguage = newValue;
                    });
                  },
                  items: _languages.map((Map<String, String> language) {
                    return DropdownMenuItem<String>(
                      value: language['code'],
                      child: Text(language['name']!),
                    );
                  }).toList(),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Enter text here',
                  border: InputBorder.none,
                ),
                maxLines: 5, // Increased size for a paragraph
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: _scanTextFromImage,
                ),
                const Spacer(),
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black)),
                  onPressed: _translateText,
                  child: const Text(
                    'Translate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
