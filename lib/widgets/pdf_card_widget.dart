import 'dart:io';
import 'package:flutter/material.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:open_file/open_file.dart';
import 'package:note_app/utils/share_position_origin.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:intl/intl.dart';

class PDFCardWidget extends StatelessWidget {
  final File pdf;
  final Function(File) onDelete;

  const PDFCardWidget({super.key, required this.pdf, required this.onDelete});

  void _sharePDF(BuildContext context) {
    Share.shareXFiles(
      [XFile(pdf.path)],
      text: 'Sharing PDF file',
      sharePositionOrigin: sharePositionOriginFor(context),
    );
  }

  Future<File?> _generatePDFPreview() async {
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

  void _openPDF() {
    ShowInterstitialAds()
        .showClickInterstitialAds(callback: () => OpenFile.open(pdf.path));
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<int>(
      iconColor: Colors.black,
      onSelected: (item) {
        switch (item) {
          case 0:
            _sharePDF(context);
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

  String _shortenFileName(String fileName) {
    return fileName.length > 6 ? '${fileName.substring(0, 6)}..' : fileName;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('yMMMd').format(File(pdf.path).lastModifiedSync());

    return GestureDetector(
      onTap: _openPDF,
      child: Card(
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(10),
          child: Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder<File?>(
                  future: _generatePDFPreview(),
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
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0XFFE0EAFC), Color(0XFFCFDEF3)],
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                    _buildPopupMenu(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
