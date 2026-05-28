// lib/features/image_text_scanner.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/styles/app_theme.dart';

class ImageTextScannerPage extends StatefulWidget {
  final Function(String) onTextScanned;

  const ImageTextScannerPage({super.key, required this.onTextScanned});

  @override
  _ImageTextScannerPageState createState() => _ImageTextScannerPageState();
}

class _ImageTextScannerPageState extends State<ImageTextScannerPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _recognizedText;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _scanText(_imageFile!);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _scanText(File image) async {
    setState(() {
      _isScanning = true;
    });

    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    setState(() {
      _recognizedText = recognizedText.text;
      _isScanning = false;
    });

    widget.onTextScanned(_recognizedText ?? '');
    Navigator.pop(context);
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
          title: const Text('Scan Image Text'),
        ),
        body: Center(
          child: _isScanning
              ? const CircularProgressIndicator()
              : _imageFile != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.file(_imageFile!),
                        const SizedBox(height: 16),
                        Text(
                          _recognizedText ?? 'Scanning...',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : const Text('No image selected.'),
        ),
      ),
    );
  }
}
