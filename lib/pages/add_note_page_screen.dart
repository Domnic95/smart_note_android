// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_app/Google_Ads/Native_Ads/NativeAdManager.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/models/model_note.dart';
import 'package:note_app/styles/app_theme.dart';
import 'package:note_app/widgets/color_and_actions_page_widget.dart';
import 'package:note_app/widgets/microphone_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_settings/open_settings.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../utils/share_position_origin.dart';
import '../utils/storage_helper_widget.dart';
import '../widgets/wizard_dialog.dart';
import '../features/floating_text_box_widget.dart';

class AddNotePage extends StatefulWidget {
  final Note? note;
  final String? scannedData;
  final TextEditingController controller;
  final bool startVoiceInput;
  final VoidCallback onClose;

  const AddNotePage({
    super.key,
    this.note,
    this.scannedData,
    required this.controller,
    required this.startVoiceInput,
    required this.onClose,
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _storageHelper = StorageHelper();
  bool isBold = false;
  final ScrollController _bottomSheetController = ScrollController();

  bool isItalic = false;
  bool isUnderline = false;
  Color selectedColor = Colors.black;
  final ImagePicker picker = ImagePicker();
  List<File> _images = [];
  List<String> _labels = ["Work", "Personal", "Important"];
  String _selectedLabel = "Work";
  List<FloatingTextBox> floatingTextBoxes = [];
  late stt.SpeechToText _speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      if (widget.note!.imagePath != null) {
        _images.add(File(widget.note!.imagePath!));
      }
    }
    if (widget.scannedData != null) {
      _contentController.text += widget.scannedData!;
    }
    if (widget.startVoiceInput) {
      _startListening();
    }
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => isListening = true);
      _speech.listen(
        onResult: (val) {
          if (mounted) {
            setState(() {
              _contentController.text += ' ${val.recognizedWords}';
            });
          }
        },
      );
    } else {
      setState(() => isListening = false);
    }
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            title.isEmpty && content.isEmpty
                ? 'Add a title and some note text before saving.'
                : title.isEmpty
                    ? 'Add a title before saving.'
                    : 'Add some note text before saving.',
          ),
        ),
      );
      return;
    }
    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: title,
      content: content,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      imagePath: _images.isNotEmpty ? _images[0].path : null,
    );
    if (widget.note == null) {
      await _storageHelper.addNote(note);
    } else {
      await _storageHelper.updateNoteById(note);
    }
    widget.onClose();
    ShowInterstitialAds()
        .showClickInterstitialAds(callback: () => Navigator.pop(context));
  }

  void _deleteNote() {
    if (widget.note != null) {
      _storageHelper.deleteNoteById(widget.note!.id);
    }
    Navigator.pop(context);
  }

  void _copyContent() {
    Clipboard.setData(ClipboardData(text: _contentController.text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note copied to clipboard")),
    );
  }

  void _shareNote() async {
    await Future.delayed(Duration.zero);
    Share.share(
      _contentController.text,
      sharePositionOrigin: sharePositionOriginFor(context),
    );
  }

  void _showLabelsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final newLabelController = TextEditingController();
        return AlertDialog(
          title: const Text("Labels"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ..._labels.map((label) {
                  return ListTile(
                    title: Text(label),
                    onTap: () {
                      setState(() {
                        _selectedLabel = label;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
                TextField(
                  controller: newLabelController,
                  enableSuggestions: true,
                  autocorrect: true,
                  decoration: const InputDecoration(hintText: 'New label'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newLabelController.text.isNotEmpty) {
                  setState(() {
                    _labels.add(newLabelController.text);
                    _selectedLabel = newLabelController.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog() {
    final noteSize = _contentController.text.length;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Details"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Title: ${_titleController.text}"),
                Text("Label: $_selectedLabel"),
                Text("Date: ${DateFormat('E, h:mm a').format(DateTime.now())}"),
                Text("Characters: ${_contentController.text.length}"),
                Text("Size: $noteSize bytes"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _saveNoteToFile,
              child: const Text('Save'),
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveNoteToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${_titleController.text}.txt');
    await Future.delayed(Duration.zero);
    await file.writeAsString(_contentController.text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Note saved to ${file.path}")),
    );
  }

  void _openSettings() {
    OpenSettings.openMainSetting();
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Details'),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openColorAndActionsPage() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: ColorAndActionsPage(
                scrollController: _bottomSheetController,
                content: _contentController.text,
                onColorSelected: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
                onDeleteNote: _deleteNote,
                onCopyContent: _copyContent,
                onShareNote: _shareNote,
                onShowLabelsDialog: _showLabelsDialog,
                onShowMoreOptions: _showMoreOptions,
                onFloatingTextBoxesAdded: (textBoxes) {},
              ),
            ),
          ),
        );
      },
    );

    if (result is XFile) {
      setState(() {
        _images.add(File(result.path));
      });
    }
  }

  void _updateNoteContent(String content) {
    if (content == 'add_text_box') {
      _addTextBox();
    } else {
      _contentController.text += "\n$content";
    }
  }

  void _addTextBox() {
    setState(() {
      floatingTextBoxes.add(FloatingTextBox(
        initialPosition: const Offset(100, 100),
        initialText: '',
        onDelete: () => _deleteTextBox(),
        onSave: (position, text) => _saveTextBox(position, text),
      ));
    });
  }

  void _deleteTextBox() {
    setState(() {
      floatingTextBoxes.removeLast();
    });
  }

  void _saveTextBox(Offset position, String text) {
    log('Saving FloatingTextBox at position: $position with text: $text');
    _contentController.text = text;
    setState(() {});
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<bool> onBackPress({void Function()? callback}) async {
    return await ShowInterstitialAds()
        .showBackClickInterstitialAds(callback: callback);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () => onBackPress(
        callback: () => Navigator.pop(context),
      ),
      child: Scaffold(
        bottomNavigationBar: const NativeAdManager(),
        appBar: AppBar(
          flexibleSpace:
              NotebookAppBarDecoration.flexibleSpaceForTheme(context),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
          actions: [
            MicrophoneWidget(controller: _contentController),
            IconButton(
              icon: const Icon(Icons.auto_fix_high_outlined),
              onPressed: () {
                WizardDialog.showWizardDialog(context, _updateNoteContent);
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    enableSuggestions: true,
                    autocorrect: true,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: RepaintBoundary(
                          child: Column(
                            children: [
                              if (_images.isNotEmpty)
                                ..._images.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  File image = entry.value;
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        child: Image.file(
                                          image,
                                          cacheWidth: 800,
                                          cacheHeight: 800,
                                          filterQuality: FilterQuality.low,
                                          gaplessPlayback: true,
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              TextField(
                                controller: _contentController,
                                scrollPhysics: const BouncingScrollPhysics(),
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: 'Start typing...',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: selectedColor == Colors.black
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                      : selectedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0XFFE0EAFC),
          onPressed: _openColorAndActionsPage,
          child: const Icon(Icons.color_lens_outlined, color: Colors.black),
        ),
      ),
    );
  }
}
