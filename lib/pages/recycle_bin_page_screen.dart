import 'package:flutter/material.dart';
import 'package:note_app/Google_Ads/Native_Ads/NativeAdManager.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/styles/app_theme.dart';
import '../models/model_note.dart';
import '../utils/storage_helper_widget.dart';
import '../widgets/note_card_widget.dart';

class RecycleBinPage extends StatefulWidget {
  const RecycleBinPage({super.key, this.notesRefreshToken});
  final ValueNotifier<int>? notesRefreshToken;

  @override
  State<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends State<RecycleBinPage> {
  final StorageHelper _storageHelper = StorageHelper();
  List<Note> _deletedNotes = [];

  @override
  void initState() {
    super.initState();
    widget.notesRefreshToken?.addListener(_onNotesRefreshTokenChanged);
    _loadDeletedNotes();
  }

  void _onNotesRefreshTokenChanged() {
    if (!mounted) return;
    _loadDeletedNotes();
  }

  void _notifyNotesChangedGlobally() {
    if (widget.notesRefreshToken != null) {
      widget.notesRefreshToken!.value++;
    } else {
      _loadDeletedNotes();
    }
  }

  Future<void> _loadDeletedNotes() async {
    final deletedNotes = await _storageHelper.readDeletedNotes();
    deletedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (!mounted) return;
    setState(() {
      _deletedNotes = deletedNotes;
    });
  }

  Future<void> _recoverNoteById(String id) async {
    await _storageHelper.recoverNoteById(id);
    if (!mounted) return;
    await _loadDeletedNotes();
    if (!mounted) return;
    _notifyNotesChangedGlobally();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Note restored!'),
    ));
  }

  Future<void> _permanentlyDeleteNoteById(String id) async {
    await _storageHelper.permanentlyDeleteNoteById(id);
    if (!mounted) return;
    await _loadDeletedNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Note permanently deleted!'),
    ));
  }

  Future<void> _recoverAllNotes() async {
    final snapshot = List<Note>.from(_deletedNotes);
    for (final note in snapshot) {
      await _storageHelper.recoverNoteById(note.id);
    }
    if (!mounted) return;
    await _loadDeletedNotes();
    if (!mounted) return;
    _notifyNotesChangedGlobally();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All notes restored!'),
    ));
  }

  Future<void> _permanentlyDeleteAllNotes() async {
    final snapshot = List<Note>.from(_deletedNotes);
    for (final note in snapshot) {
      await _storageHelper.permanentlyDeleteNoteById(note.id);
    }
    if (!mounted) return;
    await _loadDeletedNotes();
    if (!mounted) return;
    _notifyNotesChangedGlobally();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All notes permanently deleted!'),
    ));
  }

  Future<bool> onBackPress({void Function()? callback}) async {
    return await ShowInterstitialAds()
        .showBackClickInterstitialAds(callback: callback);
  }

  @override
  void dispose() {
    widget.notesRefreshToken?.removeListener(_onNotesRefreshTokenChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Recycle Bin'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _permanentlyDeleteAllNotes,
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _recoverAllNotes,
            ),
          ],
        ),
        body: _deletedNotes.isEmpty
            ? const Center(child: Text('No deleted notes available'))
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _deletedNotes.length,
                  itemBuilder: (context, index) {
                    final note = _deletedNotes[index];
                    return NoteCard(
                      note: note, // Add the note parameter
                      title: note.title,
                      content: note.content,
                      updatedAt: note.updatedAt,
                      onEdit: () {
                        // No edit functionality in recycle bin
                      },
                      onDelete: () {
                        _permanentlyDeleteNoteById(note.id);
                      },
                      isInRecycleBin: true,
                      onMenuSelected: (value) {
                        switch (value) {
                          case 'Restore':
                            _recoverNoteById(note.id);
                            break;
                          case 'Permanently Delete':
                            _permanentlyDeleteNoteById(note.id);
                            break;
                        }
                      },
                      isSelected: false,
                      onSelect: (isSelected) {},
                    );
                  },
                ),
              ),
      ),
    );
  }
}
