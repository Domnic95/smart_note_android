import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:note_app/styles/app_theme.dart';

class PhotoPickerPage extends StatefulWidget {
  @override
  _PhotoPickerPageState createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  File? _image;
  String? _recognizedText;

  Future<void> pickImageAndRecognizeText() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final text = await _recognizeText(imageFile);
      setState(() {
        _image = imageFile;
        _recognizedText = text;
      });
    }
  }

  Future<String> _recognizeText(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: NotebookAppBarDecoration.flexibleSpaceForTheme(context),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text('Photo Picker'),
      ),
      body: Center(
        child: _image == null
            ? Text('No image selected')
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(_image!),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _recognizedText ?? 'Recognizing...',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImageAndRecognizeText,
        child: Icon(Icons.photo),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: NotebookAppBarDecoration.flexibleSpaceForTheme(context),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoPickerPage(),
              ),
            );
          },
          child: Text('Open Photo Picker'),
        ),
      ),
    );
  }
}
