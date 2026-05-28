import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:note_app/Google_Ads/Native_Ads/NativeAdManager.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/models/model_note.dart';
import 'package:note_app/pages/add_note_page_screen.dart';
import 'package:note_app/styles/app_theme.dart';
import 'package:note_app/utils/share_position_origin.dart';
import 'package:note_app/utils/storage_helper_widget.dart';
import 'package:note_app/widgets/note_card_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../widgets/pdf_create_widget.dart';

class AllNotesPage extends StatefulWidget {
  const AllNotesPage({
    super.key,
    this.notesRefreshToken,
    this.searchController,
    this.isViewAll,
  });

  final ValueNotifier<int>? notesRefreshToken;
  final TextEditingController? searchController;
  final bool? isViewAll;

  @override
  State<AllNotesPage> createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  Set<Note> _selectedNotes = {};
  final StorageHelper _storageHelper = StorageHelper();
  bool _isLoading = true;
  TextEditingController? _ownedSearchController;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  TextEditingController get _searchCtl =>
      widget.searchController ?? _ownedSearchController!;
  bool _isFabVisible = false;
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  bool _isSelecting = false;
  final isAllNote = false;

  @override
  void initState() {
    super.initState();
    if (widget.searchController == null) {
      _ownedSearchController = TextEditingController();
    }
    widget.notesRefreshToken?.addListener(_onExternalNotesRefresh);
    _loadNotes();
    _searchCtl.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
  }

  void _onExternalNotesRefresh() {
    if (!mounted) return;
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });
    _notes = await _storageHelper.readNotes();
    if (!mounted) return;
    _filteredNotes = _filteredNotesForQuery(_searchCtl.text);
    setState(() {
      _isLoading = false;
    });
  }

  List<Note> _filteredNotesForQuery(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return List<Note>.from(_notes);
    return _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(q) ||
              note.content.toLowerCase().contains(q),
        )
        .toList();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredNotes = _filteredNotesForQuery(_searchCtl.text);
    });
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(
          note: note,
          controller: _noteController,
          startVoiceInput: false,
          onClose: () {},
        ),
      ),
    ).then((_) {
      _loadNotes();
    });
  }

  void _deleteNote(String id) async {
    await _storageHelper.moveNoteToRecycleBin(id);
    if (!mounted) return;
    if (widget.notesRefreshToken != null) {
      widget.notesRefreshToken!.value++;
    } else {
      _loadNotes();
    }
  }

  void _shareNote(Note note) {
    Share.share(
      '${note.title}\n\n${note.content}',
      sharePositionOrigin: sharePositionOriginFor(context),
    );
  }

  Future<void> _exportNoteToPDF(Note note) async {
    final shareOrigin = sharePositionOriginFor(context);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${note.title}.pdf';
    final file = File(filePath);

    await createPDF(file, note.title, note.content);

    if (!mounted) return;
    Share.shareXFiles(
      [XFile(filePath)],
      text: 'Here is the note exported as PDF',
      sharePositionOrigin: shareOrigin,
    );
  }

  Future<void> createPDF(File file, String title, String content) async {
    final pdfCreator = PDFCreator();
    await pdfCreator.createPDF(file, title, content);
  }

  void _onMenuSelected(String value, Note note) {
    switch (value) {
      case 'Share':
        _shareNote(note);
        break;
      case 'Export':
        _exportNoteToPDF(note);
        break;
      case 'Delete':
        _deleteNote(note.id);
        break;
    }
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = true;
        });
      }
    }

    if (_scrollController.offset >= 200) {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    } else {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _selectNoteCallback(Note note, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedNotes.add(note);
      } else {
        _selectedNotes.remove(note);
      }
      _isSelecting = _selectedNotes.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNotes.clear();
      _isSelecting = false;
    });
  }

  void _deleteSelectedNotes() async {
    for (var note in _selectedNotes) {
      await _storageHelper.moveNoteToRecycleBin(note.id);
    }
    _clearSelection();
    if (!mounted) return;
    if (widget.notesRefreshToken != null) {
      widget.notesRefreshToken!.value++;
    } else {
      _loadNotes();
    }
  }

  @override
  void dispose() {
    widget.notesRefreshToken?.removeListener(_onExternalNotesRefresh);
    _searchCtl.removeListener(_onSearchChanged);
    _ownedSearchController?.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLocalSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;
    final hint = fg.withValues(alpha: 0.65);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchCtl,
        focusNode: _searchFocusNode,
        style: theme.textTheme.titleMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w400,
            ) ??
            TextStyle(color: fg, fontSize: 18),
        cursorColor: fg,
        decoration: InputDecoration(
          hintText: 'Search title or body...',
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
                  onPressed: () {
                    _searchCtl.clear();
                  },
                ),
        ),
      ),
    );
  }

  Future<bool> onBackPress({void Function()? callback}) async {
    if (_isSelecting) {
      _clearSelection();
      return false;
    }
    return await ShowInterstitialAds()
        .showBackClickInterstitialAds(callback: callback);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () => onBackPress(callback: () => Navigator.pop(context)),
      child: Scaffold(
        appBar: widget.isViewAll ?? false
            ? AppBar(
                centerTitle: true,
                flexibleSpace:
                    NotebookAppBarDecoration.flexibleSpaceForTheme(context),
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,
                title: const Text("All Notes"),
              )
            : null,
        bottomNavigationBar:
            widget.isViewAll ?? false ? const NativeAdManager() : null,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.searchController == null)
                _buildLocalSearchField(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredNotes.isEmpty
                        ? Center(
                            child: Text(
                              _notes.isEmpty
                                  ? 'No notes available'
                                  : 'No notes match your search',
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 2 / 2.70,
                              ),
                              itemCount: _filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = _filteredNotes[
                                    _filteredNotes.length - 1 - index];
                                final isSelected =
                                    _selectedNotes.contains(note);
                                return GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      _selectedNotes.add(note);
                                      _isSelecting = true;
                                    });
                                  },
                                  onTap: () {
                                    if (_isSelecting) {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedNotes.remove(note);
                                        } else {
                                          _selectedNotes.add(note);
                                        }
                                        if (_selectedNotes.isEmpty) {
                                          _isSelecting = false;
                                        }
                                      });
                                    } else {
                                      _editNote(note);
                                    }
                                  },
                                  child: NoteCard(
                                    note: note,
                                    title: note.title,
                                    content: note.content,
                                    updatedAt: note.updatedAt,
                                    onEdit: () => ShowInterstitialAds()
                                        .showClickInterstitialAds(
                                            callback: () => _editNote(note)),
                                    onDelete: () => _deleteNote(note.id),
                                    onMenuSelected: (value) =>
                                        _onMenuSelected(value, note),
                                    isInRecycleBin: false,
                                    imagePath: note.imagePath,
                                    isSelected: isSelected,
                                    onSelect: (isSelected) =>
                                        _selectNoteCallback(note, isSelected),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
        floatingActionButton: _isSelecting
            ? FloatingActionButton(
                onPressed: _deleteSelectedNotes,
                backgroundColor: Colors.red,
                shape: const CircleBorder(),
                child: const Icon(Icons.delete, color: Colors.white),
              )
            : _isFabVisible
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: const Color.fromRGBO(255, 95, 0, 1.0),
                      child: IconButton(
                        icon: const Icon(
                          Entypo.chevron_small_up,
                          color: Colors.white,
                        ),
                        onPressed: _scrollToTop,
                      ),
                    ),
                  )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
