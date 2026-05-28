import 'package:flutter/material.dart';

/// iOS requires a non-zero anchor [Rect] in global coordinates for the share
/// popover. Passing a zero-size rect triggers a [PlatformException].
Rect sharePositionOriginFor(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box != null && box.attached && box.hasSize) {
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (rect.width >= 1 && rect.height >= 1) {
      return rect;
    }
  }
  final padding = MediaQuery.paddingOf(context);
  final size = MediaQuery.sizeOf(context);
  final center = Offset(
    size.width / 2,
    padding.top + (size.height - padding.vertical) / 2,
  );
  return Rect.fromCenter(center: center, width: 2, height: 2);
}
