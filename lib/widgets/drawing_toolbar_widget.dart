import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:note_app/features/drawing_page_screen.dart';

class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({
    super.key,
    required this.scheme,
    required this.isColorPaletteOpen,
    required this.onTogglePalette,
    required this.selectedStroke,
    required this.isEraser,
    required this.onStrokeSelected,
    required this.onClear,
    required this.selectedColor,
  });
  final ColorScheme scheme;
  final bool isColorPaletteOpen;
  final VoidCallback onTogglePalette;
  final StrokeType selectedStroke;
  final bool isEraser;
  final ValueChanged<StrokeType> onStrokeSelected;
  final VoidCallback onClear;
  final Color selectedColor;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _ToolbarToolButton(
                tooltip: 'Color palette',
                icon: Icons.palette_rounded,
                isSelected: isColorPaletteOpen,
                scheme: scheme,
                colorDot: selectedColor,
                onTap: onTogglePalette,
              ),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ToolbarToolButton(
                        tooltip: 'Pen',
                        icon: Ionicons.pencil_outline,
                        isSelected:
                            selectedStroke == StrokeType.pen && !isEraser,
                        scheme: scheme,
                        onTap: () => onStrokeSelected(StrokeType.pen),
                      ),
                      _ToolbarToolButton(
                        tooltip: 'Fine tip',
                        icon: Ionicons.create_outline,
                        isSelected:
                            selectedStroke == StrokeType.pencil && !isEraser,
                        scheme: scheme,
                        onTap: () => onStrokeSelected(StrokeType.pencil),
                      ),
                      _ToolbarToolButton(
                        tooltip: 'Marker',
                        icon: MaterialCommunityIcons.grease_pencil,
                        isSelected:
                            selectedStroke == StrokeType.marker && !isEraser,
                        scheme: scheme,
                        onTap: () => onStrokeSelected(StrokeType.marker),
                      ),
                      _ToolbarToolButton(
                        tooltip: 'Eraser',
                        icon: MaterialCommunityIcons.eraser,
                        isSelected: isEraser,
                        scheme: scheme,
                        onTap: () => onStrokeSelected(StrokeType.eraser),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _ToolbarToolButton(
                tooltip: 'Clear canvas',
                icon: Icons.layers_clear_rounded,
                isSelected: false,
                scheme: scheme,
                destructive: true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarToolButton extends StatelessWidget {
  const _ToolbarToolButton({
    required this.tooltip,
    required this.icon,
    required this.isSelected,
    required this.scheme,
    required this.onTap,
    this.colorDot,
    this.destructive = false,
  });
  final String tooltip;
  final IconData icon;
  final bool isSelected;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final Color? colorDot;
  final bool destructive;
  @override
  Widget build(BuildContext context) {
    final isDark = scheme.brightness == Brightness.dark;

    final iconColor = destructive
        ? scheme.error
        : isDark
            ? Colors.white
            : (isSelected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant);

    final selectedFill =
        isDark ? scheme.primary : scheme.primaryContainer;
    final selectedBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : scheme.primary.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? selectedFill : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? selectedBorderColor : Colors.transparent,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 22, color: iconColor),
                  if (colorDot != null && !isSelected)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorDot,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.surface,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
