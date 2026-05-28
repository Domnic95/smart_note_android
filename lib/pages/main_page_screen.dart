import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_app/Google_Ads/BannerAds/BannerAdManager.dart';
import 'package:note_app/pages/settings_page_screen.dart';
import 'package:note_app/styles/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/pages/add_note_page_screen.dart';
import 'package:note_app/pages/all_notes_page_screen.dart';
import 'package:note_app/pages/home_page_screen.dart';
import 'package:note_app/pages/pdf_page_screen.dart';
import 'package:note_app/widgets/bottom_navigation_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MainPage({super.key, required this.toggleTheme});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late TextEditingController noteController;
  final ShowInterstitialAds _ads = ShowInterstitialAds();
  late final ValueNotifier<int> _notesRefreshToken;
  late final ValueNotifier<int> _pdfRefreshToken;
  late final List<Widget> _widgetOptions;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchBarVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _pdfSearchFocusNode = FocusNode();
  bool _isPdfSearchBarVisible = false;
  final TextEditingController _pdfSearchController = TextEditingController();

  void _notifyNotesChanged() {
    _notesRefreshToken.value++;
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearchBarVisible = !_isSearchBarVisible;
      if (!_isSearchBarVisible) {
        _searchFocusNode.unfocus();
        _searchController.clear();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _togglePdfSearchBar() {
    setState(() {
      _isPdfSearchBarVisible = !_isPdfSearchBarVisible;
      if (!_isPdfSearchBarVisible) {
        _pdfSearchFocusNode.unfocus();
        _pdfSearchController.clear();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _pdfSearchFocusNode.requestFocus();
        });
      }
    });
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
      _pdfRefreshToken.value++;
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
  }

  String getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Notebook";
      case 1:
        return "All notes";
      case 2:
        return "PDF View";
      case 3:
        return "Settings";
      default:
        return "Unknown";
    }
  }

  List<Widget> getActions() {
    switch (_selectedIndex) {
      case 1:
        return [
          if (!_isSearchBarVisible)
            IconButton(
              icon: const Icon(Iconsax.search_normal_1),
              tooltip: 'Search Notes',
              onPressed: _toggleSearchBar,
            ),
        ];
      case 2:
        return [
          if (!_isPdfSearchBarVisible)
            IconButton(
              icon: const Icon(Iconsax.search_normal_1),
              tooltip: 'Search PDFs',
              onPressed: _togglePdfSearchBar,
            ),
          IconButton(
            icon: const Icon(Iconsax.document_upload),
            tooltip: 'Add PDF',
            onPressed: _pickAndAddPDF,
          ),
        ];
      default:
        return [];
    }
  }

  Widget? getLeading() {
    if (_selectedIndex == 1 && _isSearchBarVisible) {
      return IconButton(
        icon: const Icon(CupertinoIcons.clear_thick),
        tooltip: 'Close search',
        onPressed: _toggleSearchBar,
      );
    }
    if (_selectedIndex == 2 && _isPdfSearchBarVisible) {
      return IconButton(
        icon: const Icon(CupertinoIcons.clear_thick),
        tooltip: 'Close search',
        onPressed: _togglePdfSearchBar,
      );
    }
    return null;
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  Widget _buildAppBarSearchField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String fieldKey,
  }) {
    final theme = Theme.of(context);
    final fg = theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final hint = fg.withValues(alpha: 0.65);
    return TextField(
      key: ValueKey(fieldKey),
      controller: controller,
      focusNode: focusNode,
      style: theme.textTheme.titleMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w400,
          ) ??
          TextStyle(color: fg, fontSize: 18),
      cursorColor: fg,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hint),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        filled: true,
        fillColor: fg.withValues(alpha: .2),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: 24,
                  color: theme.iconTheme.color?.withValues(alpha: 0.7),
                ),
                tooltip: 'Clear',
                onPressed: () {
                  controller.clear();
                },
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController();
    _notesRefreshToken = ValueNotifier(0);
    _pdfRefreshToken = ValueNotifier(0);
    _widgetOptions = [
      HomePage(
        notesRefreshToken: _notesRefreshToken,
        pdfRefreshToken: _pdfRefreshToken,
      ),
      AllNotesPage(
        notesRefreshToken: _notesRefreshToken,
        searchController: _searchController,
      ),

      PDFPage(
        searchController: _pdfSearchController,
        pdfRefreshToken: _pdfRefreshToken,
      ),
      SettingsPageScreen(
        notesRefreshToken: _notesRefreshToken,
        toggleTheme: widget.toggleTheme,
      )
    ];

    _searchController.addListener(_onSearchTextChanged);
    _pdfSearchController.addListener(_onSearchTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final page in _widgetOptions) {
        // ignore: invalid_use_of_protected_member
        page.createElement();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _pdfSearchController.removeListener(_onSearchTextChanged);
    _notesRefreshToken.dispose();
    _pdfRefreshToken.dispose();
    noteController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pdfSearchController.dispose();
    _pdfSearchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == 1 && index != 1) {
        _searchController.clear();
      }
      if (_selectedIndex == 2 && index != 2) {
        _pdfSearchController.clear();
      }
      _selectedIndex = index;
      _isSearchBarVisible = false;
      _isPdfSearchBarVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: getLeading(),
        flexibleSpace: NotebookAppBarDecoration.flexibleSpaceForTheme(context),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: _selectedIndex == 1 && _isSearchBarVisible
            ? _buildAppBarSearchField(
                context: context,
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Search title or body...',
                fieldKey: 'search_notes',
              )
            : _selectedIndex == 2 && _isPdfSearchBarVisible
                ? _buildAppBarSearchField(
                    context: context,
                    controller: _pdfSearchController,
                    focusNode: _pdfSearchFocusNode,
                    hintText: 'Search PDFs...',
                    fieldKey: 'search_pdf',
                  )
                : Text(
                    getTitle(),
                    style: theme.appBarTheme.titleTextStyle,
                  ),
        actions: getActions(),
      ),
      body: Column(
        children: [
          const BannerAdManager(),
          Expanded(
            child: RepaintBoundary(
              child: IndexedStack(
                index: _selectedIndex,
                children: _widgetOptions,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endDocked,
        Offset(-1, -50),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton(
      onPressed: () {
        _ads.showClickInterstitialAds(
          callback: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNotePage(
                controller: noteController,
                startVoiceInput: false,
                onClose: () {},
              ),
            ),
          ).then((_) => _notifyNotesChanged()),
        );
      },
      shape: const CircleBorder(),
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      child: const Icon(
        Iconsax.note_add,
      ),
    );
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const CustomFloatingActionButtonLocation(
    this.location,
    this.offset,
  );

  final FloatingActionButtonLocation location;
  final Offset offset;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset baseOffset = location.getOffset(scaffoldGeometry);
    return Offset(baseOffset.dx + offset.dx, baseOffset.dy + offset.dy);
  }
}
