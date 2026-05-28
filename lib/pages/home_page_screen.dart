// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_app/features/drawing_page_screen.dart';
import 'package:note_app/features/qr_scanner_screen.dart';
import 'package:note_app/features/language_translation_widget.dart';
import 'package:note_app/features/document_scanner_screen.dart';
import 'package:note_app/models/model_note.dart';
import 'package:note_app/pages/add_note_page_screen.dart';
import 'package:note_app/pages/all_notes_page_screen.dart';
import 'package:note_app/pages/pdf_page_screen.dart';
import 'package:note_app/utils/storage_helper_widget.dart';
import 'package:note_app/widgets/note_card_widget.dart';
import 'package:note_app/widgets/pdf_create_widget.dart';
import 'package:note_app/widgets/pdf_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.notesRefreshToken, this.pdfRefreshToken});
  final ValueNotifier<int>? notesRefreshToken;
  final ValueNotifier<int>? pdfRefreshToken;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  static const Color _kHomeAccent = Colors.blue;

  LinearGradient _homeAccentGradient(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(cs.surface, cs.surfaceContainerHighest, 0.55)!,
          Color.lerp(cs.surfaceContainerHighest, cs.primaryContainer, 0.28)!,
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(cs.surface, cs.primaryContainer, 0.78)!,
        Color.lerp(cs.surface, cs.secondaryContainer, 0.62)!,
      ],
    );
  }

  LinearGradient _primaryActionGradient(BuildContext context) {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF1976D2),
        Color(0xFF42A5F5),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  List<Note> _notes = [];
  List<File> _pdfFiles = [];
  final StorageHelper _storageHelper = StorageHelper();
  bool _isLoading = true;
  final TextEditingController _noteController = TextEditingController();
  Note? _currentNote;

  @override
  void initState() {
    super.initState();
    widget.notesRefreshToken?.addListener(_onExternalNotesRefresh);
    widget.pdfRefreshToken?.addListener(_onExternalPdfRefresh);
    _loadData();
  }

  void _onExternalNotesRefresh() {
    if (!mounted) return;
    _loadData();
  }

  void _onExternalPdfRefresh() {
    if (!mounted) return;
    _loadData();
  }

  void _refreshNotesAcrossTabs() {
    if (!mounted) return;
    if (widget.notesRefreshToken != null) {
      widget.notesRefreshToken!.value++;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDirectory = Directory('${directory.path}/PDFs');

      final results = await Future.wait([
        _storageHelper.readNotes(),
        await pdfDirectory.exists()
            ? pdfDirectory
                .list()
                .where((file) => file.path.endsWith('.pdf'))
                .cast<File>()
                .toList()
            : Future.value(<File>[]),
      ]);

      _notes = results[0] as List<Note>;
      _pdfFiles = results[1] as List<File>;
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _editNote(Note note) {
    setState(() {
      _currentNote = note;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(
          note: note,
          controller: _noteController,
          startVoiceInput: false,
          onClose: () {
            if (!mounted) return;
            setState(() {
              _currentNote = null;
            });
          },
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _refreshNotesAcrossTabs();
    });
  }

  void _deleteNote(String id) async {
    await _storageHelper.deleteNoteById(id);
    if (!mounted) return;
    _refreshNotesAcrossTabs();
  }

  void _addNote() {
    setState(() {
      _currentNote = null;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(
          controller: _noteController,
          startVoiceInput: false,
          onClose: () {
            if (!mounted) return;
            setState(() {
              _currentNote = null;
            });
          },
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _refreshNotesAcrossTabs();
    });
  }

  void _addPDF() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPage(
          pdfRefreshToken: widget.pdfRefreshToken,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _refreshNotesAcrossTabs();
    });
  }

  Future<void> createPDF(File file, String title, String content) async {
    final pdfCreator = PDFCreator();
    await pdfCreator.createPDF(file, title, content);
  }

  void _startVoiceTyping() {
    setState(() {
      _currentNote = null;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(
          controller: _noteController,
          startVoiceInput: true,
          onClose: () {
            if (!mounted) return;
            setState(() {
              _currentNote = null;
            });
          },
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _refreshNotesAcrossTabs();
    });
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      final newNote = Note(
        id: DateTime.now().toString(),
        title: 'QR Code',
        content: result,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _storageHelper.saveNote(newNote);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNotePage(
            note: newNote,
            controller: _noteController,
            startVoiceInput: false,
            onClose: () {
              if (!mounted) return;
              setState(() {
                _currentNote = null;
              });
            },
          ),
        ),
      ).then((_) {
        if (!mounted) return;
        _refreshNotesAcrossTabs();
      });
    }
  }

  Future<void> _scanDocument() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentScannerPage(),
      ),
    );

    if (!mounted) return;

    if (result != null && result is String) {
      final newNote = Note(
        id: DateTime.now().toString(),
        title: 'Scanned Document',
        content: result,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _storageHelper.saveNote(newNote);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNotePage(
            note: newNote,
            controller: _noteController,
            startVoiceInput: false,
            onClose: () {
              if (!mounted) return;
              setState(() {
                _currentNote = null;
              });
            },
          ),
        ),
      ).then((_) {
        if (!mounted) return;
        _refreshNotesAcrossTabs();
      });
    }
  }

  Future<void> _translateText() async {
    final result = await showDialog(
      context: context,
      builder: (context) => LanguageTranslationWidget(
        note: _currentNote,
        onTranslationComplete: (translatedText, {Note? note}) async {
          if (note != null) {
            // ⚠️ TEMP FIX: pass Future instead of DateTime
            note.updateContent(
              '${note.content}\n$translatedText',
              Future.value(null), // 👈 matches Future<Null>
            );

            await _storageHelper.updateNoteById(note);

            if (mounted) {
              _refreshNotesAcrossTabs();
            }
          } else {
            final newNote = Note(
              id: DateTime.now().toString(),
              title: 'Translated Text',
              content: translatedText,
              updatedAt: DateTime.now(),
              createdAt: DateTime.now(),
            );

            await _storageHelper.saveNote(newNote);

            if (!mounted) return;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNotePage(
                  note: newNote,
                  controller: _noteController,
                  startVoiceInput: false,
                  onClose: () {
                    if (!mounted) return;
                    setState(() {
                      _currentNote = null;
                    });
                  },
                ),
              ),
            );

            if (mounted) {
              _refreshNotesAcrossTabs();
            }
          }
        },
      ),
    );

    if (result != null && mounted) {
      _refreshNotesAcrossTabs();
    }
  }

  Widget _buildStatChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int count,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        gradient: _homeAccentGradient(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 22, color: cs.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.primary,
                        ),
                      )
                    : Text(
                        '$count',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: fg,
                          height: 1.05,
                          letterSpacing: -0.5,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _buildStatChip(
              context: context,
              icon: SimpleLineIcons.note,
              label: 'Notes',
              count: _notes.length,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatChip(
              context: context,
              icon: MaterialIcons.picture_as_pdf,
              label: 'PDFs',
              count: _pdfFiles.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'Quick tools',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                  ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  context,
                  Ionicons.ios_mic_outline,
                  'Voice',
                  _startVoiceTyping,
                  1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolCard(
                  context,
                  Ionicons.ios_brush_outline,
                  'Draw',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DrawingPage(onNoteSaved: _refreshNotesAcrossTabs),
                      ),
                    );
                  },
                  3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolCard(
                  context,
                  Icons.document_scanner_outlined,
                  'Scan',
                  _scanDocument,
                  4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  context,
                  AntDesign.qrcode,
                  'QR',
                  _scanQRCode,
                  5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolCard(
                  context,
                  MaterialIcons.translate,
                  'Translate',
                  _translateText,
                  6,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolCard(
                  context,
                  MaterialIcons.picture_as_pdf,
                  'PDF',
                  _addPDF,
                  7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    int index,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = cs.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ShowInterstitialAds().showClickInterstitialAds(
          callback: () {
            if (!mounted) return;
            onTap();
          },
        ),
        child: Ink(
          height: 100,
          decoration: BoxDecoration(
            gradient: _homeAccentGradient(context),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: cs.primary),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w600,
                    height: 1.12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryAddNoteCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = cs.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => ShowInterstitialAds().showClickInterstitialAds(
            callback: () {
              if (!mounted) return;
              _addNote();
            },
          ),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              gradient: _primaryActionGradient(context),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(SimpleLineIcons.note, color: fg, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'New note',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.add_rounded, color: fg, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext themeCtx,
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    final theme = Theme.of(themeCtx);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See all',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 18, color: cs.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalNotesList(BuildContext themeCtx) {
    final reversedNotes = _notes.reversed.toList();
    final theme = Theme.of(themeCtx);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader(
          themeCtx: themeCtx,
          title: 'Recent notes',
          subtitle: _notes.isEmpty
              ? 'Tap “New note” to get started'
              : '${_notes.length} saved',
          onSeeAll: () {
            ShowInterstitialAds().showClickInterstitialAds(
              callback: () {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllNotesPage(
                      notesRefreshToken: widget.notesRefreshToken,
                      isViewAll: true,
                    ),
                  ),
                );
              },
            );
          },
        ),
        SizedBox(
          height: 217.0,
          child: _notes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'No notes yet — your recent notes will show here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                )
              : RepaintBoundary(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = reversedNotes[index];
                      return Container(
                        width: 150,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 16 : 6,
                          right: index == _notes.length - 1 ? 16 : 6,
                        ),
                        child: NoteCard(
                          note: note,
                          // index: index,
                          title: note.title,
                          content: note.content,
                          updatedAt: note.updatedAt,
                          onEdit: () => ShowInterstitialAds()
                              .showClickInterstitialAds(callback: () {
                            if (!mounted) return;
                            _editNote(note);
                          }),
                          onDelete: () => _deleteNote(note.id),
                          onMenuSelected: (value) => {},
                          isInRecycleBin: false,
                          imagePath: note.imagePath,
                          isSelected: false,
                          onSelect: (isSelected) {},
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHorizontalPDFsList(BuildContext themeCtx) {
    final reversedPdfs = _pdfFiles.reversed.toList();
    final theme = Theme.of(themeCtx);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader(
          themeCtx: themeCtx,
          title: 'Recent PDFs',
          subtitle: _pdfFiles.isEmpty
              ? 'Export or open PDFs from tools'
              : '${_pdfFiles.length} on device',
          onSeeAll: () {
            ShowInterstitialAds().showClickInterstitialAds(
              callback: () {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFPage(
                      pdfRefreshToken: widget.pdfRefreshToken,
                    ),
                  ),
                );
              },
            );
          },
        ),
        SizedBox(
          height: 200.0,
          child: _pdfFiles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'No PDFs yet — create one from the PDF tool above.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                )
              : RepaintBoundary(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pdfFiles.length,
                    itemBuilder: (context, index) {
                      final pdf = reversedPdfs[index];
                      return Container(
                        width: 151,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 16 : 6,
                          right: index == _pdfFiles.length - 1 ? 16 : 6,
                        ),
                        child: PDFCardWidget(
                          pdf: pdf,
                          onDelete: (file) async {
                            try {
                              if (await file.exists()) {
                                await file.delete();
                              }
                              if (mounted) {
                                setState(() {
                                  _pdfFiles.remove(file);
                                });
                              }
                            } catch (e) {
                              debugPrint("Delete error: $e");
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.notesRefreshToken?.removeListener(_onExternalNotesRefresh);
    widget.pdfRefreshToken?.removeListener(_onExternalPdfRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final parentTheme = Theme.of(context);
    final homeScheme = ColorScheme.fromSeed(
      seedColor: _kHomeAccent,
      brightness: parentTheme.brightness,
    );
    final homeTheme = parentTheme.copyWith(
      colorScheme: homeScheme,
      primaryColor: _kHomeAccent,
    );

    return Theme(
      data: homeTheme,
      child: Builder(
        builder: (themeCtx) {
          final cs = Theme.of(themeCtx).colorScheme;
          return Scaffold(
            backgroundColor: cs.surface,
            body: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                const SizedBox(height: 4),
                _buildStatsRow(themeCtx),
                _buildPrimaryAddNoteCard(themeCtx),
                _buildToolsGrid(themeCtx),
                _buildHorizontalNotesList(themeCtx),
                _buildHorizontalPDFsList(themeCtx),
              ],
            ),
          );
        },
      ),
    );
  }
}
