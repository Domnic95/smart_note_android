import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:note_app/models/model_note.dart';
import 'package:note_app/utils/share_position_origin.dart';
import 'package:note_app/widgets/pdf_create_widget.dart';
import 'package:share_plus/share_plus.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final String title;
  final String content;
  final DateTime updatedAt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isInRecycleBin;
  final Function(String) onMenuSelected;
  final String? imagePath;
  final bool isSelected;
  final ValueChanged<bool> onSelect;

  const NoteCard({
    super.key,
    required this.note,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.onEdit,
    required this.onDelete,
    required this.onMenuSelected,
    required this.isInRecycleBin,
    this.imagePath,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: _homeAccentGradient(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.32)
                : cs.outlineVariant.withValues(alpha: 0.10),
            width: isSelected ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.10)
                  : cs.shadow.withValues(alpha: 0.045),
              blurRadius: isSelected ? 18 : 12,
              spreadRadius: -3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onEdit,
          onLongPress: () => onSelect(!isSelected),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final hasImage = imagePath != null;
                  final maxH = constraints.maxHeight;
                  final maxW = constraints.maxWidth;
                  final compact = maxH.isFinite && maxH < 260;
                  final previewMaxLines = compact ? 3 : 6;
                  final compactTitle = compact || maxW < 160;

                  if (!maxH.isFinite) {
                    return _NoteCardLooseBody(
                      theme: theme,
                      cs: cs,
                      hasImage: hasImage,
                      imagePath: imagePath,
                      title: title,
                      content: content,
                      updatedAt: updatedAt,
                      isSelected: isSelected,
                      isInRecycleBin: isInRecycleBin,
                      onMenuSelected: _onMenuSelected,
                      contentMaxLines: 5,
                      compactTitle: maxW < 160,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage) ...[
                        Flexible(
                          flex: 5,
                          fit: FlexFit.tight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(imagePath!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: cs.surfaceContainerHigh,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      _NoteCardTitleRow(
                        theme: theme,
                        cs: cs,
                        title: title,
                        isSelected: isSelected,
                        isInRecycleBin: isInRecycleBin,
                        onMenuSelected: _onMenuSelected,
                        compactTitle: compactTitle,
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        flex: hasImage ? 3 : 1,
                        fit: FlexFit.tight,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            content,
                            maxLines: previewMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.45,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _NoteCardDateRow(
                          theme: theme, cs: cs, updatedAt: updatedAt),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _homeAccentGradient(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(cs.surface, cs.surfaceContainerHighest, 0.72)!,
          Color.lerp(cs.surfaceContainerHighest, cs.primaryContainer, 0.48)!,
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(cs.surface, cs.primaryContainer, 0.90)!,
        Color.lerp(cs.surface, cs.secondaryContainer, 0.78)!,
      ],
    );
  }

  void _onMenuSelected(String value, BuildContext context) {
    switch (value) {
      case 'Share':
        _shareNote(context);
        break;

      case 'Export':
        _exportNoteToPDF(context);
        break;

      case 'Delete':
        onDelete();
        break;

      case 'Restore':
        onMenuSelected('Restore');
        break;

      case 'Permanently Delete':
        onMenuSelected('Permanently Delete');
        break;
    }
  }

  void _shareNote(BuildContext context) {
    Share.share(
      '$title\n\n$content',
      sharePositionOrigin: sharePositionOriginFor(context),
    );
  }

  Future<void> _exportNoteToPDF(BuildContext context) async {
    final pdfCreator = PDFCreator();

    final filePath = await pdfCreator.createPDFFromNote(note);

    Share.shareXFiles(
      [XFile(filePath)],
      text: 'Here is the note exported as PDF',
      sharePositionOrigin: sharePositionOriginFor(context),
    );
  }
}

class _NoteCardTitleRow extends StatelessWidget {
  const _NoteCardTitleRow({
    required this.theme,
    required this.cs,
    required this.title,
    required this.isSelected,
    required this.isInRecycleBin,
    required this.onMenuSelected,
    this.compactTitle = false,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String title;
  final bool isSelected;
  final bool isInRecycleBin;
  final void Function(String, BuildContext) onMenuSelected;
  final bool compactTitle;

  @override
  Widget build(BuildContext context) {
    final titleStyle = (compactTitle
            ? theme.textTheme.titleSmall
            : theme.textTheme.titleMedium)
        ?.copyWith(
      fontWeight: FontWeight.w700,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            title.trim().isEmpty ? 'Untitled' : title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ),
        if (isSelected)
          Icon(
            Iconsax.tick_circle5,
            color: cs.primary,
            size: 22,
          ),
        PopupMenuButton<String>(
          icon: const Icon(Iconsax.more),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onSelected: (value) => onMenuSelected(value, context),
          itemBuilder: (context) {
            if (isInRecycleBin) {
              return const [
                PopupMenuItem(
                  value: 'Restore',
                  child: Text('Restore'),
                ),
                PopupMenuItem(
                  value: 'Permanently Delete',
                  child: Text('Delete Permanently'),
                ),
              ];
            }

            return const [
              PopupMenuItem(
                value: 'Share',
                child: Text('Share'),
              ),
              PopupMenuItem(
                value: 'Export',
                child: Text('Export PDF'),
              ),
              PopupMenuItem(
                value: 'Delete',
                child: Text('Delete'),
              ),
            ];
          },
        ),
      ],
    );
  }
}

class _NoteCardDateRow extends StatelessWidget {
  const _NoteCardDateRow({
    required this.theme,
    required this.cs,
    required this.updatedAt,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Iconsax.calendar_1,
          size: 15,
          color: cs.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NoteCardLooseBody extends StatelessWidget {
  const _NoteCardLooseBody({
    required this.theme,
    required this.cs,
    required this.hasImage,
    required this.imagePath,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.isSelected,
    required this.isInRecycleBin,
    required this.onMenuSelected,
    required this.contentMaxLines,
    required this.compactTitle,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool hasImage;
  final String? imagePath;
  final String title;
  final String content;
  final DateTime updatedAt;
  final bool isSelected;
  final bool isInRecycleBin;
  final void Function(String, BuildContext) onMenuSelected;
  final int contentMaxLines;
  final bool compactTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: cs.surfaceContainerHigh,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        _NoteCardTitleRow(
          theme: theme,
          cs: cs,
          title: title,
          isSelected: isSelected,
          isInRecycleBin: isInRecycleBin,
          onMenuSelected: onMenuSelected,
          compactTitle: compactTitle,
        ),
        const SizedBox(height: 6),
        Text(
          content,
          maxLines: contentMaxLines,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.45,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        _NoteCardDateRow(theme: theme, cs: cs, updatedAt: updatedAt),
      ],
    );
  }
}
