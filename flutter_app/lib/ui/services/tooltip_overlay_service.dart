import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class TooltipOverlayService {
  OverlayEntry? _entry;
  Timer? _dismissTimer;

  void show({
    required BuildContext context,
    required Offset globalPosition,
    required String text,
    String? imageAssetPath,
  }) {
    dispose();

    final overlay = Overlay.of(context);
    final media = MediaQuery.of(context);
    final colours = Theme.of(context).colorScheme;
    const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    const margin = 8.0;
    final hasImage = imageAssetPath != null && imageAssetPath.isNotEmpty;
    final contentWidth = math.min(
      256.0,
      math.max(1.0, media.size.width - 2 * margin - padding.horizontal),
    );
    final textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      inherit: false,
      color: colours.onSurface,
      fontSize: 14,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: Directionality.of(context),
      textScaler: media.textScaler,
    )..layout(maxWidth: contentWidth);
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;
    textPainter.dispose();
    final previewSize = math.min(
      contentWidth,
      math.max(
        1.0,
        media.size.height - 2 * margin - padding.vertical - textHeight - 8,
      ),
    );
    final tooltipSize = Size(
      (hasImage ? contentWidth : textWidth) + padding.horizontal,
      (hasImage ? previewSize + 8 : 0) + textHeight + padding.vertical,
    );
    final left = (globalPosition.dx - tooltipSize.width / 2).clamp(
      margin,
      math.max(margin, media.size.width - tooltipSize.width - margin),
    );
    final top = (globalPosition.dy - tooltipSize.height - 14).clamp(
      margin,
      math.max(margin, media.size.height - tooltipSize.height - margin),
    );

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        left: left.toDouble(),
        top: top.toDouble(),
        width: tooltipSize.width,
        child: IgnorePointer(
          child: Material(
            key: const ValueKey('tile-preview-overlay'),
            color: colours.surface,
            elevation: 4,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasImage) ...[
                    SizedBox(
                      width: previewSize,
                      height: previewSize,
                      child: Image(
                        image: imageAssetPath.startsWith('/')
                            ? FileImage(File(imageAssetPath))
                            : AssetImage(imageAssetPath) as ImageProvider,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    textScaler: media.textScaler,
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
    _dismissTimer = Timer(Duration(seconds: hasImage ? 4 : 2), dispose);
  }

  void dispose() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _entry?.remove();
    _entry = null;
  }
}
