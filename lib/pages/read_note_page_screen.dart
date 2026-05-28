import 'package:flutter/material.dart';
import 'package:note_app/styles/app_theme.dart';
import '../models/model_note.dart';

class ReadNotePage extends StatelessWidget {
  final Note note;

  ReadNotePage({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: NotebookAppBarDecoration.flexibleSpaceForTheme(context),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(note.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note.content),
      ),
    );
  }
}
