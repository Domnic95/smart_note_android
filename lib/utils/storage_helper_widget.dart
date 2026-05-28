// lib/utils/storage_helper.dart

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/model_note.dart';
import '../models/model_pdf.dart';

class StorageHelper {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes.json');
  }

  Future<File> get _recycleBinFile async {
    final path = await _localPath;
    return File('$path/recycle_bin.json');
  }

  Future<File> get _pdfFile async {
    final path = await _localPath;
    return File('$path/pdfs.json');
  }

  Future<List<Note>> readNotes() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonResponse = json.decode(contents);
        return jsonResponse.map((note) => Note.fromJson(note)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Note>> readDeletedNotes() async {
    try {
      final file = await _recycleBinFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonResponse = json.decode(contents);
        return jsonResponse.map((note) => Note.fromJson(note)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<File> writeNotes(List<Note> notes) async {
    final file = await _localFile;
    return file.writeAsString(
        json.encode(notes.map((note) => note.toJson()).toList()));
  }

  Future<File> writeDeletedNotes(List<Note> notes) async {
    final file = await _recycleBinFile;
    return file.writeAsString(
        json.encode(notes.map((note) => note.toJson()).toList()));
  }

  Future<void> deleteNoteById(String id) async {
    List<Note> notes = await readNotes();
    Note? deletedNote;
    try {
      deletedNote = notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return;
    }

    if (deletedNote != null) {
      notes.removeWhere((note) => note.id == id);
      await writeNotes(notes);

      List<Note> deletedNotes = await readDeletedNotes();
      deletedNotes.add(deletedNote);
      await writeDeletedNotes(deletedNotes);
    }
  }

  Future<void> addNote(Note note) async {
    List<Note> notes = await readNotes();
    notes.add(note);
    await writeNotes(notes);
  }

  Future<void> updateNoteById(Note updatedNote) async {
    List<Note> notes = await readNotes();
    notes = notes
        .map((note) => note.id == updatedNote.id ? updatedNote : note)
        .toList();
    await writeNotes(notes);
  }

  Future<void> recoverNoteById(String id) async {
    List<Note> deletedNotes = await readDeletedNotes();
    Note? recoveredNote;
    try {
      recoveredNote = deletedNotes.firstWhere((note) => note.id == id);
    } catch (e) {
      return;
    }

    if (recoveredNote != null) {
      deletedNotes.removeWhere((note) => note.id == id);
      await writeDeletedNotes(deletedNotes);

      List<Note> notes = await readNotes();
      notes.add(recoveredNote);
      await writeNotes(notes);
    }
  }

  Future<void> permanentlyDeleteNoteById(String id) async {
    List<Note> deletedNotes = await readDeletedNotes();
    deletedNotes.removeWhere((note) => note.id == id);
    await writeDeletedNotes(deletedNotes);
  }

  Future<void> moveNoteToRecycleBin(String id) async {
    List<Note> notes = await readNotes();
    Note? noteToDelete;
    try {
      noteToDelete = notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return;
    }

    if (noteToDelete != null) {
      notes.removeWhere((note) => note.id == id);
      await writeNotes(notes);

      List<Note> deletedNotes = await readDeletedNotes();
      deletedNotes.add(noteToDelete);
      await writeDeletedNotes(deletedNotes);
    }
  }

  Future<List<PDF>> readPDFs() async {
    try {
      final file = await _pdfFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonResponse = json.decode(contents);
        return jsonResponse.map((pdf) => PDF.fromJson(pdf)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<PDF>> readDeletedPDFs() async {
    try {
      final file = await _recycleBinFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonResponse = json.decode(contents);
        return jsonResponse.map((pdf) => PDF.fromJson(pdf)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<File> writePDFs(List<PDF> pdfs) async {
    final file = await _pdfFile;
    return file
        .writeAsString(json.encode(pdfs.map((pdf) => pdf.toJson()).toList()));
  }

  Future<File> writeDeletedPDFs(List<PDF> pdfs) async {
    final file = await _recycleBinFile;
    return file
        .writeAsString(json.encode(pdfs.map((pdf) => pdf.toJson()).toList()));
  }

  Future<void> deletePDFById(String id) async {
    List<PDF> pdfs = await readPDFs();
    PDF? deletedPDF;
    try {
      deletedPDF = pdfs.firstWhere((pdf) => pdf.id == id);
    } catch (e) {
      return;
    }

    if (deletedPDF != null) {
      pdfs.removeWhere((pdf) => pdf.id == id);
      await writePDFs(pdfs);

      List<PDF> deletedPDFs = await readDeletedPDFs();
      deletedPDFs.add(deletedPDF);
      await writeDeletedPDFs(deletedPDFs);
    }
  }

  Future<void> recoverPDFById(String id) async {
    List<PDF> deletedPDFs = await readDeletedPDFs();
    PDF? recoveredPDF;
    try {
      recoveredPDF = deletedPDFs.firstWhere((pdf) => pdf.id == id);
    } catch (e) {
      return;
    }

    if (recoveredPDF != null) {
      deletedPDFs.removeWhere((pdf) => pdf.id == id);
      await writeDeletedPDFs(deletedPDFs);

      List<PDF> pdfs = await readPDFs();
      pdfs.add(recoveredPDF);
      await writePDFs(pdfs);
    }
  }

  Future<void> permanentlyDeletePDFById(String id) async {
    List<PDF> deletedPDFs = await readDeletedPDFs();
    deletedPDFs.removeWhere((pdf) => pdf.id == id);
    await writeDeletedPDFs(deletedPDFs);
  }

  Future<void> movePDFToRecycleBin(String id) async {
    List<PDF> pdfs = await readPDFs();
    PDF? pdfToDelete;
    try {
      pdfToDelete = pdfs.firstWhere((pdf) => pdf.id == id);
    } catch (e) {
      return;
    }

    if (pdfToDelete != null) {
      pdfs.removeWhere((pdf) => pdf.id == id);
      await writePDFs(pdfs);

      List<PDF> deletedPDFs = await readDeletedPDFs();
      deletedPDFs.add(pdfToDelete);
      await writeDeletedPDFs(deletedPDFs);
    }
  }

  Future<List<dynamic>> getRecentlyUsedNotesAndPDFs() async {
    final notes = await readNotes();
    final pdfs = await readPDFs();
    final List<dynamic> combinedList = [...notes, ...pdfs];
    combinedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return combinedList.take(5).toList();
  }

  Future<void> saveNote(Note newNote) async {
    List<Note> notes = await readNotes();
    notes.add(newNote);
    await writeNotes(notes);
  }
}
