# flutter_draw_dashed_line
Library for drawing dashed lines in Flutter.

### Usage:

Draw a dashed rectangle with animated dashes that move around the border:

```dart
class DashedRectWidget extends StatefulWidget {
  const DashedRectWidget({super.key});

  @override
  State<DashedRectWidget> createState() => _DashedRectWidgetState();
}

class _DashedRectWidgetState extends State<DashedRectWidget> {
  var dashOffset = 0.0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Update dash offset every 100ms
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        dashOffset += 1.5;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      height: width,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: DashedRectPainter(
            rect: const Rect.fromLTWH(0, 0, 100, 100),
            colorOuter: Colors.blueGrey,
            colorInner: Colors.white,
            strokeWidthOuter: 3.5,
            strokeWidthInner: 1.5,
            dashLen: 15.0,
            gapLen: 5.0,
            offset: dashOffset,
          ),
        ),
      ),
    );
  }
}
```

You can also use `DashedPathGenerator.generatePathFromPolyline` or `DashedPathGenerator.generatePathFromRect` to generate dashed `Path` objects that you can manually render.
