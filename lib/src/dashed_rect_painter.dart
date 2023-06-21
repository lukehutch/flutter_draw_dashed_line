// The flutter_draw_dashed_line library.
// (C) 2023 Luke Hutchison, MIT-licensed.
// Hosted at https://github.com/lukehutch/flutter_draw_dashed_line

import 'package:flutter/material.dart';
import 'package:flutter_draw_dashed_line/src/dashed_path_generator.dart';

class DashedRectPainter extends CustomPainter {
  final Rect rect;
  final Color colorOuter;
  final Color colorInner;
  final double strokeWidthOuter;
  final double strokeWidthInner;
  final double dashLen;
  final double gapLen;
  final double offset;

  DashedRectPainter({
    required this.rect,
    required this.colorOuter,
    required this.colorInner,
    required this.strokeWidthOuter,
    required this.strokeWidthInner,
    required this.dashLen,
    required this.gapLen,
    required this.offset,
  })  : assert(strokeWidthOuter > strokeWidthInner),
        assert(dashLen > strokeWidthOuter - strokeWidthInner);

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.colorOuter != colorOuter ||
      oldDelegate.colorInner != colorInner ||
      oldDelegate.strokeWidthOuter != strokeWidthOuter ||
      oldDelegate.strokeWidthInner != strokeWidthInner ||
      oldDelegate.dashLen != dashLen ||
      oldDelegate.gapLen != gapLen ||
      oldDelegate.offset != offset;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidthDiff = strokeWidthOuter - strokeWidthInner;
    // Draw outer lines
    canvas.drawPath(
      DashedPathGenerator.generatePathFromRect(
        rect: rect,
        dashLen: dashLen,
        gapLen: gapLen,
        offset: offset,
      ),
      Paint()
        ..strokeWidth = strokeWidthOuter
        ..color = colorOuter
        ..style = PaintingStyle.stroke,
    );
    // Draw inner lines
    canvas.drawPath(
      DashedPathGenerator.generatePathFromRect(
        rect: rect,
        dashLen: dashLen - strokeWidthDiff,
        gapLen: gapLen + strokeWidthDiff,
        offset: offset - strokeWidthDiff / 2,
      ),
      Paint()
        ..strokeWidth = strokeWidthInner
        ..color = colorInner
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool hitTest(Offset position) => rect.contains(position);
}
