import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/widgets.dart';

class FloatingTextBox extends StatefulWidget {
  final Offset initialPosition;
  final String initialText;
  final Function onDelete; // Callback function for deletion
  final Function onSave; // Callback function for saving position and text

  const FloatingTextBox(
      {super.key,
      required this.initialPosition,
      required this.initialText,
      required this.onDelete,
      required this.onSave});

  @override
  _FloatingTextBoxState createState() => _FloatingTextBoxState();
}

class _FloatingTextBoxState extends State<FloatingTextBox> {
  late Offset position;
  late double width;
  late double height;
  late double rotationAngle;
  final TextEditingController _controller = TextEditingController();
  bool isDragging = false; // Flag to track dragging state
  bool showDeleteIcon = false; // Flag to show delete icon

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
    width = 200;
    height = 100;
    rotationAngle = 0;
    _controller.text = widget.initialText;
  }

  void _updatePosition(Offset newPosition) {
    setState(() {
      position = newPosition;
    });
  }

  void _updateSize(double newWidth, double newHeight) {
    setState(() {
      width = newWidth;
      height = newHeight;
    });
  }

  void _updateRotation(double newAngle) {
    setState(() {
      rotationAngle = newAngle;
    });
  }

  void _showDeleteIcon(bool show) {
    setState(() {
      showDeleteIcon = show;
    });
  }

  void _deleteTextBox() {
    widget.onDelete();
    _showDeleteIcon(false);
  }

  void _saveTextBox() {
    widget.onSave(position, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              _updatePosition(Offset(position.dx + details.delta.dx,
                  position.dy + details.delta.dy));
            },
            onPanEnd: (details) {
              setState(() {
                isDragging = false; // Reset dragging state
                _saveTextBox(); // Save the position and text on drag end
              });
            },
            onPanStart: (details) {
              setState(() {
                isDragging = true; // Set dragging state
              });
            },
            onLongPress: () {
              _showDeleteIcon(true); // Show delete icon on long press
            },
            child: Transform.rotate(
              angle: rotationAngle,
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        _saveTextBox();
                        setState(() {});
                      },
                      controller: _controller,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -20,
                    left: width / 2 - 10,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final centerX = position.dx + width / 2;
                        final centerY = position.dy + height / 2;
                        final dx = details.globalPosition.dx - centerX;
                        final dy = details.globalPosition.dy - centerY;
                        final newAngle = atan2(dy, dx);
                        _updateRotation(newAngle);
                      },
                      child: const Icon(Icons.refresh, color: Colors.orange),
                    ),
                  ),
                  ..._buildResizeHandles(),
                ],
              ),
            ),
          ),
        ),
        if (showDeleteIcon)
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: GestureDetector(
              onTap: _deleteTextBox,
              child: const Icon(Icons.delete, color: Colors.red, size: 60),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildResizeHandles() {
    return [
      _buildResizeHandle(const Offset(0, 0)),
      _buildResizeHandle(Offset(width / 2, 0)),
      _buildResizeHandle(Offset(width, 0)),
      _buildResizeHandle(Offset(0, height / 2)),
      _buildResizeHandle(Offset(width, height / 2)),
      _buildResizeHandle(Offset(0, height)),
      _buildResizeHandle(Offset(width / 2, height)),
      _buildResizeHandle(Offset(width, height)),
    ];
  }

  Widget _buildResizeHandle(Offset handlePosition) {
    return Positioned(
      left: handlePosition.dx - 10,
      top: handlePosition.dy - 10,
      child: GestureDetector(
        onPanUpdate: (details) {
          final newWidth =
              width + details.delta.dx * (handlePosition.dx == width ? 1 : -1);
          final newHeight = height +
              details.delta.dy * (handlePosition.dy == height ? 1 : -1);
          _updateSize(max(50, newWidth), max(50, newHeight));
        },
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
