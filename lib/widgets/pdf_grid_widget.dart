import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:note_app/utils/share_position_origin.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'dart:math';

class PDFGrid extends StatelessWidget {
  final List<File> pdfFiles;
  final Function(File) onDelete;

  const PDFGrid({super.key, required this.pdfFiles, required this.onDelete});

  void _sharePDF(BuildContext context, File pdf) {
    Share.shareXFiles(
      [XFile(pdf.path)],
      text: 'Sharing PDF file',
      sharePositionOrigin: sharePositionOriginFor(context),
    );
  }

  Future<File?> _generatePDFPreview(File pdf) async {
    PdfDocument? document;
    PdfPage? page;
    try {
      document = await PdfDocument.openFile(pdf.path);
      page = await document.getPage(1);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: PdfPageImageFormat.png,
      );
      if (pageImage == null) return null;
      final bytes = pageImage.bytes;

      final previewDir = (await getTemporaryDirectory()).path;
      final previewFile = File('$previewDir/${pdf.path.split('/').last}.png');
      await previewFile.writeAsBytes(bytes);

      return previewFile;
    } catch (e) {
      // ignore: avoid_print
      print('Error generating PDF preview: $e');
      return null;
    } finally {
      await page?.close();
      await document?.close();
    }
  }

  void _openPDF(File pdf) {
    OpenFile.open(pdf.path);
  }

  Widget _buildPopupMenu(BuildContext context, File pdf) {
    return PopupMenuButton<int>(
      onSelected: (item) {
        switch (item) {
          case 0:
            _sharePDF(context, pdf);
            break;
          case 1:
            onDelete(pdf);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<int>(value: 0, child: Text('Share')),
        const PopupMenuItem<int>(value: 1, child: Text('Delete')),
      ],
    );
  }

  Widget _buildPdfCard(BuildContext context, File pdf) {
    final String formattedDate =
        DateFormat('yMMMd').format(File(pdf.path).lastModifiedSync());

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange
    ];
    final Color color = colors[Random().nextInt(colors.length)];
    final Color gradientStart = color.withOpacity(0.8);
    final Color gradientEnd = color.withOpacity(0.4);

    return GestureDetector(
      onTap: () => _openPDF(pdf),
      child: Card(
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<File?>(
                future: _generatePDFPreview(pdf),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(snapshot.data!,
                          fit: BoxFit.cover, width: double.infinity);
                    } else {
                      return const Center(
                        child: Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 50),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _shortenFileName(pdf.path.split('/').last),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  _buildPopupMenu(context, pdf),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortenFileName(String fileName) {
    return fileName.length > 6 ? '${fileName.substring(0, 6)}..' : fileName;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: pdfFiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 2 / 4, // Adjusted aspect ratio for longer cards
      ),
      itemBuilder: (context, index) {
        final pdf = pdfFiles[index];
        return _buildPdfCard(context, pdf);
      },
    );
  }
}
