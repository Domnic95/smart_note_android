// lib/widgets/wizard_dialog.dart

import 'package:flutter/material.dart';
import 'package:note_app/features/document_scanner_screen.dart';
import 'package:note_app/features/drawing_page_screen.dart';
import 'package:note_app/features/qr_scanner_screen.dart';
import 'package:note_app/features/language_translation_widget.dart'; // Import the LanguageTranslationWidget
import 'package:note_app/features/image_text_scanner_screen.dart'; // Import the ImageTextScannerPage
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:note_app/utils/storage_helper_widget.dart';
import 'package:note_app/models/model_note.dart';

class WizardDialog {
  static void showWizardDialog(
      BuildContext context, Function(String) onResult) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageTextScannerPage(
                              onTextScanned: (scannedText) {
                                onResult('Scanned text: $scannedText');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(MaterialIcons.translate),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LanguageTranslationWidget(
                              onTranslationComplete: (translation,
                                  {Note? note}) {
                                onResult('Translation: $translation');
                                if (note != null) {
                                  note.updateContent(
                                      '${note.content}\n$translation',
                                      DateTime.now() as Future<Null>);
                                  StorageHelper().updateNoteById(note);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.document_scanner_outlined),
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const DocumentScannerPage()),
                        );
                        if (result != null && result is String) {
                          onResult(result);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QRScannerPage()),
                        );
                        if (result != null && result is String) {
                          onResult(result);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    // ListTile(
                    //   leading: const Icon(AntDesign.aliwangwang_o1),
                    //   title: const Text('AI content writer'),
                    //   onTap: () async {
                    //     Navigator.pop(context);
                    //     showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return ai_widget.AICommandWidget(
                    //           onResult: onResult,
                    //         );
                    //       },
                    //     );
                    //   },
                    // ),
                    ListTile(
                      leading: const Icon(Icons.brush),
                      title: const Text('Drawing'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DrawingPage(onNoteSaved: () {
                              Navigator.of(context).pop();
                              onResult('Drawing saved');
                            }),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.text_fields),
                      title: const Text('Text Box'),
                      onTap: () {
                        Navigator.pop(context);
                        onResult('add_text_box');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
