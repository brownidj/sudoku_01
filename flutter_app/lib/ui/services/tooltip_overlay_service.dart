import 'package:flutter/material.dart';

class TooltipOverlayService {
  OverlayEntry? _entry;

  void show({
    required BuildContext context,
    required Offset globalPosition,
    required String text,
    String? imageAssetPath,
  }) {
    _entry?.remove();

    final overlay = Overlay.of(context);
    if (overlay == null) {
      return;
    }

    final size = MediaQuery.of(context).size;
    const tooltipPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    const tooltipMargin = 8.0;
    const previewSize = 256.0;
    final hasImage = imageAssetPath != null && imageAssetPath.isNotEmpty;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: hasImage ? previewSize : double.infinity);
    final tooltipSize = Size(
      hasImage
          ? previewSize + tooltipPadding.horizontal
          : textPainter.width + tooltipPadding.horizontal,
      (hasImage ? previewSize + 10 : 0) +
          textPainter.height +
          tooltipPadding.vertical,
    );

    var left = globalPosition.dx - tooltipSize.width / 2;
    var top = globalPosition.dy - tooltipSize.height - 14;
    left = left.clamp(
      tooltipMargin,
      size.width - tooltipSize.width - tooltipMargin,
    );
    top = top.clamp(
      tooltipMargin,
      size.height - tooltipSize.height - tooltipMargin,
    );

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: tooltipPadding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasImage)
                  Container(
                    width: previewSize,
                    height: previewSize,
                    color: Colors.white,
                    child: Image.asset(
                      imageAssetPath!,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                if (hasImage) const SizedBox(height: 10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
    Future<void>.delayed(const Duration(seconds: 2), () {
      _entry?.remove();
      _entry = null;
    });
  }

  void dispose() {
    _entry?.remove();
    _entry = null;
  }
}
