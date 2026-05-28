import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:note_app/models/model_note.dart';

class PDFCreator {
  Future<void> createPDF(File file, String title, String content) async {
    final pdf = pw.Document();

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              content,
              style: pw.TextStyle(fontSize: 16, font: ttf),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final pdfFile = File('${output.path}/${file.path}');

    await pdfFile.writeAsBytes(await pdf.save());
  }

  Future<String> createPDFFromNote(Note note) async {
    final pdf = pw.Document();

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              note.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              note.content,
              style: const pw.TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/${note.title}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}
