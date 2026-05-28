// lib/features/drawing_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:note_app/Google_Ads/Native_Ads/NativeAdManager.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/styles/app_theme.dart';
import 'package:note_app/widgets/drawing_toolbar_widget.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/model_note.dart';
import '../utils/storage_helper_widget.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPage extends StatefulWidget {
  final Note? note;
  final Function() onNoteSaved;

  const DrawingPage({super.key, required this.onNoteSaved, this.note});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  final ValueNotifier<List<DrawnPoint>> _pointsNotifier = ValueNotifier([]);
  final _storageHelper = StorageHelper();
  Color _selectedColor = Colors.black;
  bool _isColorBarVisible = false;
  late AnimationController _controller;
  StrokeType _selectedStrokeType = StrokeType.pen;
  bool _isEraserMode = false;

  final List<Color> _restrictedColors = [
    Colors.red,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null && (widget.note!.imagePath?.isNotEmpty ?? false)) {
      _loadDrawing(widget.note!.imagePath!);
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _loadDrawing(String path) async {
    final file = File(path);
    if (await file.exists()) {
      _pointsNotifier.value = [
        DrawnPoint(null, Colors.transparent, StrokeType.pen),
      ];
    }
  }

  void _toggleColorBar() {
    setState(() {
      _isColorBarVisible = !_isColorBarVisible;
      if (_isColorBarVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Size _drawingExportSize() {
    final ctx = _canvasKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final w = box.size.width;
        final h = box.size.height;
        if (w > 0 && h > 0) {
          return Size(w, h);
        }
      }
    }
    return const Size(400, 400);
  }

  void _saveDrawing() async {
    if (_pointsNotifier.value.length < 2) {
      return;
    }

    final exportSize = _drawingExportSize();
    final w = exportSize.width.ceil().clamp(1, 8192);
    final h = exportSize.height.ceil().clamp(1, 8192);

    final picture = _createPicture(Size(w.toDouble(), h.toDouble()));
    final image = await picture.toImage(w, h);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final directory = (await getApplicationDocumentsDirectory()).path;
    final path = '$directory/${const Uuid().v4()}.png';
    final file = File(path);
    await file.writeAsBytes(pngBytes);

    final newNote = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: widget.note?.title ?? 'Drawing',
      content: widget.note?.content ?? 'Drawing created on ${DateTime.now()}',
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      imagePath: path,
    );

    await _storageHelper.addNote(newNote);
    widget.onNoteSaved();
    onBackPress(
      callback: () => Navigator.pop(context),
    );
  }

  ui.Picture _createPicture(Size logicalSize) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final bounds = logicalSize;
    canvas.drawRect(
      Offset.zero & bounds,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    final paint = Paint()..strokeCap = StrokeCap.round;

    final points = _pointsNotifier.value;

    canvas.saveLayer(
      Offset.zero & bounds,
      Paint(),
    );

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != null && points[i + 1].offset != null) {
        paint.strokeWidth = _getStrokeWidth(points[i].strokeType);

        if (points[i].strokeType == StrokeType.eraser) {
          paint.blendMode = BlendMode.clear;
        } else {
          paint.blendMode = BlendMode.srcOver;
          paint.color = points[i].color;
        }

        canvas.drawLine(
          points[i].offset!,
          points[i + 1].offset!,
          paint,
        );
      }
    }
    canvas.restore();
    return recorder.endRecording();
  }

  double _getStrokeWidth(StrokeType strokeType) {
    switch (strokeType) {
      case StrokeType.pen:
        return 2.0;
      case StrokeType.pencil:
        return 1.0;
      case StrokeType.marker:
        return 5.0;
      case StrokeType.eraser:
        return 18.0;
    }
  }

  void _pickCustomColor(BuildContext context) {
    Color pickerColor = _selectedColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a custom color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                if (!_restrictedColors.contains(color)) {
                  pickerColor = color;
                }
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                if (!_restrictedColors.contains(pickerColor)) {
                  setState(() {
                    _selectedColor = pickerColor;
                    _isEraserMode = false;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setStrokeType(StrokeType type) {
    setState(() {
      _selectedStrokeType = type;
      _isEraserMode = type == StrokeType.eraser;
    });
  }

  void _clearAll() {
    _pointsNotifier.value = [];
  }

  Future<bool> onBackPress({void Function()? callback}) async {
    return await ShowInterstitialAds()
        .showBackClickInterstitialAds(callback: callback);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pointsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () => onBackPress(
        callback: () => Navigator.pop(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace:
              NotebookAppBarDecoration.flexibleSpaceForTheme(context),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text('Draw'),
          // leading: IconButton(
          // icon: const Icon(Icons.arrow_back),
          //   onPressed: _saveDrawing,
          // ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.check,
                size: 28,
              ),
              onPressed: _saveDrawing,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: DrawingToolbar(
                scheme: scheme,
                isColorPaletteOpen: _isColorBarVisible,
                onTogglePalette: _toggleColorBar,
                selectedStroke: _selectedStrokeType,
                isEraser: _isEraserMode,
                onStrokeSelected: _setStrokeType,
                onClear: _clearAll,
                selectedColor: _selectedColor,
              ),
            ),
            if (_isColorBarVisible)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: _ColorPaletteCard(
                  scheme: scheme,
                  children: [
                    ..._buildColorChoices(),
                    _CustomColorChip(
                      scheme: scheme,
                      onTap: () => _pickCustomColor(context),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ClipRect(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    final points = List<DrawnPoint>.from(_pointsNotifier.value);

                    points.add(
                      DrawnPoint(
                        details.localPosition,
                        _isEraserMode ? Colors.transparent : _selectedColor,
                        _isEraserMode ? StrokeType.eraser : _selectedStrokeType,
                      ),
                    );

                    _pointsNotifier.value = points;
                  },
                  onPanEnd: (_) {
                    final points = List<DrawnPoint>.from(_pointsNotifier.value);

                    points.add(
                      DrawnPoint(
                        null,
                        Colors.transparent,
                        StrokeType.pen,
                      ),
                    );

                    _pointsNotifier.value = points;
                  },
                  child: Container(
                    key: _canvasKey,
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: ValueListenableBuilder<List<DrawnPoint>>(
                      valueListenable: _pointsNotifier,
                      builder: (_, points, __) {
                        return RepaintBoundary(
                          child: CustomPaint(
                            painter: _DrawingPainter(
                              points: points,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const NativeAdManager(),
      ),
    );
  }

  List<Widget> _buildColorChoices() {
    final colors = [
      Colors.black,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.grey,
      Colors.pink,
      Colors.teal,
      Colors.lime,
      Colors.indigo,
      Colors.amber,
      Colors.deepOrange,
      Colors.cyan,
    ];

    return colors.map((color) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedColor = color;
            _isEraserMode = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  _selectedColor == color ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawnPoint> points;
  _DrawingPainter({
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    canvas.saveLayer(
      Offset.zero & size,
      Paint(),
    );

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != null && points[i + 1].offset != null) {
        paint.strokeWidth = _getStrokeWidth(points[i].strokeType);
        if (points[i].strokeType == StrokeType.eraser) {
          paint.blendMode = BlendMode.clear;
        } else {
          paint.blendMode = BlendMode.srcOver;
          paint.color = points[i].color;
        }
        canvas.drawLine(
          points[i].offset!,
          points[i + 1].offset!,
          paint,
        );
      }
    }
    canvas.restore();
  }

  double _getStrokeWidth(StrokeType strokeType) {
    switch (strokeType) {
      case StrokeType.pen:
        return 2.0;
      case StrokeType.pencil:
        return 1.0;
      case StrokeType.marker:
        return 5.0;
      case StrokeType.eraser:
        return 18.0;
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class DrawnPoint {
  final Offset? offset;
  final Color color;
  final StrokeType strokeType;

  DrawnPoint(this.offset, this.color, this.strokeType);
}

enum StrokeType { pen, pencil, marker, eraser }

class _ColorPaletteCard extends StatelessWidget {
  const _ColorPaletteCard({
    required this.scheme,
    required this.children,
  });
  final ColorScheme scheme;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: scheme.shadow.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(18),
      color: scheme.surfaceContainerLow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _CustomColorChip extends StatelessWidget {
  const _CustomColorChip({
    required this.scheme,
    required this.onTap,
  });
  final ColorScheme scheme;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Custom color',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF6B6B),
                  Color(0xFFFFD93D),
                  Color(0xFF6BCB77),
                  Color(0xFF4D96FF),
                  Color(0xFFB983FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              color: scheme.surface,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
