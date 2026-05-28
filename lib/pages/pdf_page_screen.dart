import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_app/Google_Ads/Native_Ads/NativeAdManager.dart';
import 'package:note_app/styles/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:note_app/widgets/pdf_card_widget.dart';

import '../Google_Ads/ShowAds.dart' show ShowInterstitialAds;

class PDFPage extends StatefulWidget {
  const PDFPage({
    super.key,
    this.searchController,
    this.pdfRefreshToken,
  });

  final TextEditingController? searchController;
  final ValueNotifier<int>? pdfRefreshToken;

  @override
  State<PDFPage> createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  List<File> _pdfFiles = [];
  List<File> _filteredPdfFiles = [];
  TextEditingController? _ownedSearchController;

  TextEditingController get _searchCtl =>
      widget.searchController ?? _ownedSearchController!;

  bool get _embeddedInMain => widget.searchController != null;

  @override
  void initState() {
    super.initState();
    if (widget.searchController == null) {
      _ownedSearchController = TextEditingController();
    }
    widget.pdfRefreshToken?.addListener(_onExternalPdfRefresh);
    _loadPDFFiles();
    _searchCtl.addListener(_filterPDFs);
  }

  void _onExternalPdfRefresh() {
    if (!mounted) return;
    _loadPDFFiles();
  }

  void _applyFilter() {
    final query = _searchCtl.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredPdfFiles = List<File>.from(_pdfFiles);
    } else {
      _filteredPdfFiles = _pdfFiles
          .where(
            (pdf) => pdf.path.split('/').last.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  Future<void> _loadPDFFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory('${directory.path}/PDFs');
    if (!mounted) return;
    if (await pdfDirectory.exists()) {
      final pdfFiles = pdfDirectory
          .listSync()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();
      setState(() {
        _pdfFiles = pdfFiles.cast<File>();
        _applyFilter();
      });
    } else {
      setState(() {
        _pdfFiles = [];
        _filteredPdfFiles = [];
      });
    }
  }

  void _filterPDFs() {
    if (!mounted) return;
    setState(_applyFilter);
  }

  Future<void> _pickAndAddPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || !mounted) return;
      final file = result.files.single;
      if (file.path == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final pdfDirectory = Directory('${directory.path}/PDFs');
      if (!await pdfDirectory.exists()) {
        await pdfDirectory.create(recursive: true);
      }

      final sourceFile = File(file.path!);
      final destinationPath = '${pdfDirectory.path}/${file.name}';
      await sourceFile.copy(destinationPath);

      if (!mounted) return;

      await _loadPDFFiles();
      widget.pdfRefreshToken?.value++;
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
  }

  Widget _buildStandaloneSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;
    final hint = fg.withValues(alpha: 0.65);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchCtl,
        style: theme.textTheme.titleMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w400,
            ) ??
            TextStyle(color: fg, fontSize: 18),
        cursorColor: fg,
        decoration: InputDecoration(
          hintText: 'Search PDFs...',
          hintStyle: TextStyle(color: hint),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          filled: true,
          fillColor: fg.withValues(alpha: .08),
          suffixIcon: _searchCtl.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    CupertinoIcons.clear_circled_solid,
                    size: 24,
                    color: theme.iconTheme.color?.withValues(alpha: 0.7),
                  ),
                  tooltip: 'Clear',
                  onPressed: () => _searchCtl.clear(),
                ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    const extraAddTile = 1;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredPdfFiles.length + extraAddTile,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        if (index == _filteredPdfFiles.length) {
          return GestureDetector(
            onTap: _pickAndAddPDF,
            child: const Card(
              child: Center(
                child: Icon(Icons.add, size: 50),
              ),
            ),
          );
        }

        final pdf = _filteredPdfFiles[index];
        return PDFCardWidget(
          pdf: pdf,
          onDelete: (file) async {
            await file.delete();
            _loadPDFFiles();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    widget.pdfRefreshToken?.removeListener(_onExternalPdfRefresh);
    _searchCtl.removeListener(_filterPDFs);
    _ownedSearchController?.dispose();
    super.dispose();
  }

  Future<bool> onBackPress({void Function()? callback}) async {
    return await ShowInterstitialAds()
        .showBackClickInterstitialAds(callback: callback);
  }

  @override
  Widget build(BuildContext context) {
    if (_embeddedInMain) {
      return _buildGrid();
    }

    return WillPopScope(
      onWillPop: () => onBackPress(
        callback: () => Navigator.pop(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace:
              NotebookAppBarDecoration.flexibleSpaceForTheme(context),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text("All PDFs"),
        ),
        bottomNavigationBar: const NativeAdManager(),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStandaloneSearchField(context),
              Expanded(child: _buildGrid()),
            ],
          ),
        ),
      ),
    );
  }
}
