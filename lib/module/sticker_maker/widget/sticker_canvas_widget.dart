import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsappstickermaker/common/theme/app_theme.dart';
import 'package:whatsappstickermaker/module/sticker_maker/controller/sticker_maker_controller.dart';
import 'package:whatsappstickermaker/module/sticker_maker/data/model/brush_stroke.dart';
import 'package:whatsappstickermaker/module/sticker_maker/data/model/text_layer.dart';

class StickerCanvasWidget extends StatelessWidget {
  final StickerMakerController controller;

  const StickerCanvasWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final processedBytes = controller.processedImageBytes.value;
      final processedUiImg = controller.processedUiImage.value;
      if (processedBytes == null || processedUiImg == null) {
        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkSecondarySystemGroupedBackground
                : AppTheme.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0x38FFFFFF) : const Color(0x1F000000),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.photo_on_rectangle,
                size: 56,
                color: isDark ? AppTheme.darkSecondaryLabel : AppTheme.secondaryLabel,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Belum ada gambar.\nPilih gambar dari galeri untuk mulai membuat stiker.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppTheme.darkSecondaryLabel : AppTheme.secondaryLabel,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RepaintBoundary(
        key: controller.canvasGlobalKey,
        child: Container(
          width: 320,
          height: 320,
          decoration: controller.isExporting.value
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
          child: ClipRRect(
            borderRadius: controller.isExporting.value
                ? BorderRadius.zero
                : BorderRadius.circular(18),
            child: GestureDetector(
              onPanStart: (details) {
                controller.handlePanStart(details.localPosition);
              },
              onPanUpdate: (details) {
                controller.handlePanUpdate(details.localPosition, details.delta);
              },
              onPanEnd: (_) {
                controller.handlePanEnd();
              },
              onTapUp: (details) {
                controller.handleTap(details.localPosition);
              },
              child: CustomPaint(
                size: const Size(320, 320),
                painter: StickerCanvasPainter(
                  originalImage: controller.originalUiImage.value,
                  processedImage: controller.processedUiImage.value,
                  strokes: controller.strokes.toList(),
                  currentStroke: controller.currentStroke.value,
                  textLayers: controller.textLayers.toList(),
                  selectedTextLayerId: controller.selectedTextLayerId.value,
                  brushSize: controller.brushSize.value,
                  brushMode: controller.brushMode.value,
                  isExporting: controller.isExporting.value,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class StickerCanvasPainter extends CustomPainter {
  final ui.Image? originalImage;
  final ui.Image? processedImage;
  final List<BrushStroke> strokes;
  final BrushStroke? currentStroke;
  final List<TextLayer> textLayers;
  final String? selectedTextLayerId;
  final double brushSize;
  final CanvasBrushMode brushMode;
  final bool isExporting;

  StickerCanvasPainter({
    this.originalImage,
    this.processedImage,
    required this.strokes,
    this.currentStroke,
    required this.textLayers,
    this.selectedTextLayerId,
    required this.brushSize,
    required this.brushMode,
    this.isExporting = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Draw Checkerboard Background (only if not exporting)
    if (!isExporting) {
      _drawCheckerboard(canvas, size);
    }

    if (processedImage == null) return;

    final imageSize = Size(
      processedImage!.width.toDouble(),
      processedImage!.height.toDouble(),
    );
    final srcRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);

    final FittedSizes fitted = applyBoxFit(BoxFit.contain, imageSize, size);
    final Size dstSize = fitted.destination;
    final Rect dstRect = Rect.fromLTWH(
      (size.width - dstSize.width) / 2,
      (size.height - dstSize.height) / 2,
      dstSize.width,
      dstSize.height,
    );

    // 2. Base Cutout + Erase/Restore Strokes
    canvas.saveLayer(rect, Paint());

    canvas.drawImageRect(processedImage!, srcRect, dstRect, Paint());

    final allStrokes = [...strokes];
    if (currentStroke != null) {
      allStrokes.add(currentStroke!);
    }

    for (final stroke in allStrokes) {
      if (stroke.points.length < 2 && stroke.points.isNotEmpty) {
        _drawStrokePoint(canvas, stroke, dstRect, srcRect);
      } else if (stroke.points.length >= 2) {
        _drawStrokePath(canvas, stroke, dstRect, srcRect);
      }
    }

    canvas.restore();

    // 3. Text Layers
    for (final textLayer in textLayers) {
      _drawTextLayer(canvas, textLayer, !isExporting && textLayer.id == selectedTextLayerId);
    }
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    const double checkSize = 12.0;
    final Paint lightPaint = Paint()..color = const Color(0xFFEEEEEE);
    final Paint darkPaint = Paint()..color = const Color(0xFFDDDDDD);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), lightPaint);

    for (double y = 0; y < size.height; y += checkSize) {
      for (double x = 0; x < size.width; x += checkSize) {
        if (((x / checkSize).floor() + (y / checkSize).floor()) % 2 == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, checkSize, checkSize),
            darkPaint,
          );
        }
      }
    }
  }

  void _drawStrokePoint(
    Canvas canvas,
    BrushStroke stroke,
    Rect dstRect,
    Rect srcRect,
  ) {
    final point = stroke.points.first;
    if (stroke.mode == CanvasBrushMode.erase) {
      final paint = Paint()
        ..color = Colors.transparent
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, stroke.size / 2, paint);
    } else if (stroke.mode == CanvasBrushMode.restore && originalImage != null) {
      canvas.saveLayer(dstRect, Paint());
      final maskPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, stroke.size / 2, maskPaint);
      final imgPaint = Paint()..blendMode = BlendMode.srcIn;
      canvas.drawImageRect(originalImage!, srcRect, dstRect, imgPaint);
      canvas.restore();
    }
  }

  void _drawStrokePath(
    Canvas canvas,
    BrushStroke stroke,
    Rect dstRect,
    Rect srcRect,
  ) {
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }

    if (stroke.mode == CanvasBrushMode.erase) {
      final paint = Paint()
        ..color = Colors.transparent
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, paint);
    } else if (stroke.mode == CanvasBrushMode.restore && originalImage != null) {
      canvas.saveLayer(dstRect, Paint());
      final maskPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, maskPaint);

      final imgPaint = Paint()..blendMode = BlendMode.srcIn;
      canvas.drawImageRect(originalImage!, srcRect, dstRect, imgPaint);
      canvas.restore();
    }
  }

  void _drawTextLayer(Canvas canvas, TextLayer textLayer, bool isSelected) {
    final style = GoogleFonts.getFont(
      textLayer.fontFamily,
      fontSize: 26 * textLayer.scale,
      fontWeight: FontWeight.bold,
    );

    // 1. Outline / Stroke
    if (textLayer.strokeWidth > 0) {
      final strokeStyle = style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = textLayer.strokeWidth * textLayer.scale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = textLayer.strokeColor,
      );

      final strokePainter = TextPainter(
        text: TextSpan(text: textLayer.text, style: strokeStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      strokePainter.layout();
      final strokeOffset = Offset(
        textLayer.position.dx - strokePainter.width / 2,
        textLayer.position.dy - strokePainter.height / 2,
      );
      strokePainter.paint(canvas, strokeOffset);
    }

    // 2. Fill Text
    final fillPainter = TextPainter(
      text: TextSpan(
        text: textLayer.text,
        style: style.copyWith(color: textLayer.color),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    fillPainter.layout();
    final fillOffset = Offset(
      textLayer.position.dx - fillPainter.width / 2,
      textLayer.position.dy - fillPainter.height / 2,
    );
    fillPainter.paint(canvas, fillOffset);

    // 3. Selection Box
    if (isSelected) {
      final textRect = Rect.fromLTWH(
        fillOffset.dx - 8,
        fillOffset.dy - 6,
        fillPainter.width + 16,
        fillPainter.height + 12,
      );
      final borderPaint = Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(textRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StickerCanvasPainter oldDelegate) {
    return true;
  }
}
