// The flutter_draw_dashed_line library.
// (C) 2023 Luke Hutchison, MIT-licensed.
// Hosted at https://github.com/lukehutch/flutter_draw_dashed_line

import 'package:flutter/material.dart';

/// Generates a dashed [Path], given a series of points.
class DashedPathGenerator {
  late Offset currPoint;
  final double dashLen;
  final double gapLen;
  double lineRemaining = 0.0;
  double offset;
  final Path path = Path();

  DashedPathGenerator(
      Offset startPoint, this.dashLen, this.gapLen, this.offset) {
    currPoint = startPoint;
    // Move to start point
    path.moveTo(currPoint.dx, currPoint.dy);
  }

  int _compare(double a, double b) {
    double diff = a - b;
    return diff < -1.0e-4
        ? -1
        : diff > 1.0e-4
            ? 1
            : 0;
  }

  bool _moveForward(Offset stepDirectionNormalized) {
    // Get offset wrapped modulo (0, dashLen + gapLen)
    final patternLen = dashLen + gapLen;
    final offsetWrapped = offset % patternLen;
    // Determine how far to step to get to next boundary
    double stepSize;
    bool drawToNext;
    if (_compare(offsetWrapped, 0.0) == 0 ||
        _compare(offsetWrapped, patternLen) == 0) {
      // Starting a dash
      stepSize = dashLen;
      drawToNext = true;
    } else {
      switch (_compare(offsetWrapped, dashLen)) {
        case -1: // In the middle of a dash
          stepSize = dashLen - offsetWrapped;
          drawToNext = true;
          break;
        case 0: // At the end of a dash
          stepSize = gapLen;
          drawToNext = false;
        case 1: // In the middle of a gap
          stepSize = patternLen - offsetWrapped;
          drawToNext = false;
        default:
          throw 'Should not happen';
      }
    }
    // See if this step takes the drawing to or past the end of the line
    bool lineUnfinished;
    if (stepSize >= lineRemaining) {
      stepSize = lineRemaining;
      lineUnfinished = false;
    } else {
      lineUnfinished = true;
    }
    lineRemaining -= stepSize;
    offset += stepSize;
    // Move forward
    currPoint += stepDirectionNormalized * stepSize;
    // Draw or move to the next point
    if (drawToNext) {
      path.lineTo(currPoint.dx, currPoint.dy);
    } else {
      path.moveTo(currPoint.dx, currPoint.dy);
    }
    // Return whether the current line has ended
    return lineUnfinished;
  }

  void drawDashedLineTo(Offset nextPoint) {
    final lineVector = nextPoint - currPoint;
    lineRemaining = lineVector.distance;
    final stepDirectionNormalized = lineVector / lineRemaining;
    while (true) {
      if (!_moveForward(stepDirectionNormalized)) {
        break;
      }
    }
  }

  /// Generate a dashed [Path] from a polyline, represented by a series of
  /// [Offset]s. The polyline can be treated as an open or closed polygon.
  /// [dashLen] is the length of each dash, [gapLen] is the length of the
  /// gaps between the dashes, and [offset] is the offset into the repeating
  /// dash-gap pattern to start rendering from.
  static Path generatePathFromPolyline(
      {required List<Offset> polyline,
      required double dashLen,
      required double gapLen,
      required double offset,
      required bool isClosedPolygon}) {
    if (polyline.isEmpty) {
      return Path();
    }
    final pathState = DashedPathGenerator(polyline[0], dashLen, gapLen, offset);
    polyline
        .skip(1)
        .forEach((nextPoint) => pathState.drawDashedLineTo(nextPoint));
    if (isClosedPolygon) {
      pathState.drawDashedLineTo(polyline[0]);
    }
    return pathState.path;
  }

  /// Generate a dashed [Path] from a [Rect].
  /// [dashLen] is the length of each dash, [gapLen] is the length of the
  /// gaps between the dashes, and [offset] is the offset into the repeating
  /// dash-gap pattern to start rendering from.
  static Path generatePathFromRect(
      {required Rect rect,
      required double dashLen,
      required double gapLen,
      required double offset}) {
    return generatePathFromPolyline(
      polyline: [
        rect.topLeft,
        rect.topRight,
        rect.bottomRight,
        rect.bottomLeft
      ],
      dashLen: dashLen,
      gapLen: gapLen,
      offset: offset,
      isClosedPolygon: true,
    );
  }
}
