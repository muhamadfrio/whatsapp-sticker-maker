import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:whatsappstickermaker/module/sticker_maker/data/model/brush_stroke.dart';
import 'package:whatsappstickermaker/module/sticker_maker/data/model/text_layer.dart';

class StickerItem {
  Uint8List? originalImageBytes;
  Uint8List? processedImageBytes;
  ui.Image? originalUiImage;
  ui.Image? processedUiImage;

  bool isBackgroundRemoved;
  double backgroundSensitivity;
  List<double>? cachedConfidences;
  int? cachedMaskWidth;
  int? cachedMaskHeight;
  String? currentImagePath;

  List<BrushStroke> strokes;
  List<TextLayer> textLayers;

  StickerItem({
    this.originalImageBytes,
    this.processedImageBytes,
    this.originalUiImage,
    this.processedUiImage,
    this.isBackgroundRemoved = false,
    this.backgroundSensitivity = 0.3,
    this.cachedConfidences,
    this.cachedMaskWidth,
    this.cachedMaskHeight,
    this.currentImagePath,
    List<BrushStroke>? strokes,
    List<TextLayer>? textLayers,
  })  : strokes = strokes ?? [],
        textLayers = textLayers ?? [];

  bool get hasImage => processedImageBytes != null && processedUiImage != null;

  void reset() {
    originalImageBytes = null;
    processedImageBytes = null;
    originalUiImage = null;
    processedUiImage = null;
    isBackgroundRemoved = false;
    backgroundSensitivity = 0.3;
    cachedConfidences = null;
    cachedMaskWidth = null;
    cachedMaskHeight = null;
    currentImagePath = null;
    strokes.clear();
    textLayers.clear();
  }
}
