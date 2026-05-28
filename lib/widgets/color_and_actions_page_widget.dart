import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ColorAndActionsPage extends StatefulWidget {
  final ScrollController scrollController;
  final String content;
  final Function(Color) onColorSelected;
  final Function() onDeleteNote;
  final Function() onCopyContent;
  final Function() onShareNote;
  final Function() onShowLabelsDialog;
  final Function() onShowMoreOptions;

  const ColorAndActionsPage({
    super.key,
    required this.scrollController,
    required this.content,
    required this.onColorSelected,
    required this.onDeleteNote,
    required this.onCopyContent,
    required this.onShareNote,
    required this.onShowLabelsDialog,
    required this.onShowMoreOptions,
    required Null Function(dynamic textBoxes) onFloatingTextBoxesAdded,
  });

  @override
  _ColorAndActionsPageState createState() => _ColorAndActionsPageState();
}

class _ColorAndActionsPageState extends State<ColorAndActionsPage> {
  Color selectedColor = Colors.black;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
      Navigator.pop(context,
          _pickedImage); // Return the selected image to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (Color color in [
                    Colors.blue,
                    Colors.yellow,
                    Colors.white,
                    Colors.purple,
                    Colors.pink,
                    Colors.green,
                    Colors.orange,
                    Colors.black,
                  ])
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                        widget.onColorSelected(color);
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 16,
                        child: selectedColor == color
                            ? const Icon(Icons.check,
                                color: Colors.black, size: 18)
                            : null,
                      ),
                    ),
                ],
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.white),
                title: const Text('Delete note',
                    style: TextStyle(color: Colors.white)),
                onTap: widget.onDeleteNote,
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.white),
                title: const Text('Make a copy',
                    style: TextStyle(color: Colors.white)),
                onTap: widget.onCopyContent,
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title:
                    const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: widget.onShareNote,
              ),
              ListTile(
                leading: const Icon(Icons.label, color: Colors.white),
                title:
                    const Text('Labels', style: TextStyle(color: Colors.white)),
                onTap: widget.onShowLabelsDialog,
              ),
              const Divider(color: Colors.white),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate,
                        color: Colors.white),
                    onPressed: _pickImage,
                  ),
                  Text(
                    '${DateFormat('E, h:mm a').format(DateTime.now())} | ${widget.content.length} characters',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: widget.onShowMoreOptions,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
