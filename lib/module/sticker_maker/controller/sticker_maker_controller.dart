import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../data/model/brush_stroke.dart';
import '../data/model/text_layer.dart';

enum StickerToolMode { none, erase, restore, text }

class StickerMakerController extends GetxController {
  final ImagePicker imagePicker;
  final SelfieSegmenter selfieSegmenter;

  StickerMakerController({
    required this.imagePicker,
    required this.selfieSegmenter,
  });

  // Images
  final Rxn<Uint8List> originalImageBytes = Rxn<Uint8List>();
  final Rxn<Uint8List> processedImageBytes = Rxn<Uint8List>();
  final Rxn<ui.Image> originalUiImage = Rxn<ui.Image>();
  final Rxn<ui.Image> processedUiImage = Rxn<ui.Image>();

  final RxBool isLoading = false.obs;

  // Tools & Brush State
  final Rx<StickerToolMode> activeTool = StickerToolMode.none.obs;
  final Rx<CanvasBrushMode> brushMode = CanvasBrushMode.none.obs;
  final RxDouble brushSize = 20.0.obs;
  final RxList<BrushStroke> strokes = <BrushStroke>[].obs;
  final Rxn<BrushStroke> currentStroke = Rxn<BrushStroke>();

  // Text Layers State
  final RxList<TextLayer> textLayers = <TextLayer>[].obs;
  final RxnString selectedTextLayerId = RxnString();
  TextLayer? _draggedTextLayer;

  // Font and Color Constants
  final List<String> fontOptions = const ['Poppins', 'Bebas Neue', 'Pacifico'];
  final List<Color> colorOptions = const [
    Colors.white,
    Colors.black,
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
  ];

  TextLayer? get selectedTextLayer {
    if (selectedTextLayerId.value == null) return null;
    return textLayers.firstWhereOrNull(
      (layer) => layer.id == selectedTextLayerId.value,
    );
  }

  Future<void> pickImageAndRemoveBackground() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      isLoading.value = true;
      resetState();

      final origBytes = await File(pickedFile.path).readAsBytes();
      originalImageBytes.value = origBytes;
      originalUiImage.value = await _bytesToUiImage(origBytes);

      final resultBytes = await compute(
        _processSegmentation,
        _SegmentationParam(
          imagePath: pickedFile.path,
          selfieSegmenter: selfieSegmenter,
        ),
      );

      if (resultBytes != null) {
        processedImageBytes.value = resultBytes;
        processedUiImage.value = await _bytesToUiImage(resultBytes);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memproses gambar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetState() {
    strokes.clear();
    currentStroke.value = null;
    textLayers.clear();
    selectedTextLayerId.value = null;
    activeTool.value = StickerToolMode.none;
    brushMode.value = CanvasBrushMode.none;
  }

  static Future<Uint8List?> _processSegmentation(_SegmentationParam param) async {
    final inputImage = InputImage.fromFilePath(param.imagePath);
    final mask = await param.selfieSegmenter.processImage(inputImage);
    if (mask == null) return null;

    final imageBytes = await File(param.imagePath).readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    final resizedImage = img.copyResize(
      decodedImage,
      width: mask.width,
      height: mask.height,
    );

    final transparentImage = img.Image(
      width: mask.width,
      height: mask.height,
      numChannels: 4,
    );

    final confidences = mask.confidences;
    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        final index = y * mask.width + x;
        final confidence = confidences[index];
        final pixel = resizedImage.getPixel(x, y);

        if (confidence > 0.5) {
          final alpha = (confidence * 255).clamp(0, 255).toInt();
          transparentImage.setPixelRgba(
            x,
            y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            alpha,
          );
        } else {
          transparentImage.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    return Uint8List.fromList(img.encodePng(transparentImage));
  }

  Future<ui.Image> _bytesToUiImage(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  // Tool Selection
  void selectTool(StickerToolMode mode) {
    if (activeTool.value == mode) {
      activeTool.value = StickerToolMode.none;
      brushMode.value = CanvasBrushMode.none;
    } else {
      activeTool.value = mode;
      if (mode == StickerToolMode.erase) {
        brushMode.value = CanvasBrushMode.erase;
      } else if (mode == StickerToolMode.restore) {
        brushMode.value = CanvasBrushMode.restore;
      } else {
        brushMode.value = CanvasBrushMode.none;
      }
    }
  }

  void setBrushSize(double size) {
    brushSize.value = size;
  }

  void undoLastStroke() {
    if (strokes.isNotEmpty) {
      strokes.removeLast();
    }
  }

  void clearStrokes() {
    strokes.clear();
  }

  // Text Layer Operations
  void addTextLayer(String text) {
    if (text.trim().isEmpty) return;
    final newLayer = TextLayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      position: const Offset(160, 160),
    );
    textLayers.add(newLayer);
    selectedTextLayerId.value = newLayer.id;
    activeTool.value = StickerToolMode.text;
    brushMode.value = CanvasBrushMode.none;
  }

  void updateSelectedText(String text) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.text = text;
      textLayers.refresh();
    }
  }

  void updateSelectedTextColor(Color color) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.color = color;
      textLayers.refresh();
    }
  }

  void updateSelectedTextStrokeColor(Color color) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.strokeColor = color;
      textLayers.refresh();
    }
  }

  void updateSelectedTextStrokeWidth(double width) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.strokeWidth = width;
      textLayers.refresh();
    }
  }

  void updateSelectedTextFontFamily(String fontFamily) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.fontFamily = fontFamily;
      textLayers.refresh();
    }
  }

  void removeSelectedTextLayer() {
    if (selectedTextLayerId.value != null) {
      textLayers.removeWhere((l) => l.id == selectedTextLayerId.value);
      selectedTextLayerId.value = null;
    }
  }

  // Pan / Gesture Handlers
  void handlePanStart(Offset localPosition) {
    // 1. Check if hit any TextLayer (reverse order for top-most layer first)
    TextLayer? hitLayer;
    for (int i = textLayers.length - 1; i >= 0; i--) {
      final layer = textLayers[i];
      if ((localPosition - layer.position).distance < 50) {
        hitLayer = layer;
        break;
      }
    }

    if (hitLayer != null) {
      selectedTextLayerId.value = hitLayer.id;
      _draggedTextLayer = hitLayer;
      activeTool.value = StickerToolMode.text;
      brushMode.value = CanvasBrushMode.none;
      return;
    }

    // 2. If no text layer hit, start brush stroke if brushMode is active
    if (brushMode.value != CanvasBrushMode.none) {
      currentStroke.value = BrushStroke(
        points: [localPosition],
        size: brushSize.value,
        mode: brushMode.value,
      );
    } else {
      selectedTextLayerId.value = null;
    }
  }

  void handlePanUpdate(Offset localPosition, Offset delta) {
    if (_draggedTextLayer != null) {
      _draggedTextLayer!.position += delta;
      textLayers.refresh();
    } else if (currentStroke.value != null) {
      currentStroke.value!.points.add(localPosition);
      currentStroke.refresh();
    }
  }

  void handlePanEnd() {
    _draggedTextLayer = null;
    if (currentStroke.value != null) {
      strokes.add(currentStroke.value!);
      currentStroke.value = null;
    }
  }

  void handleTap(Offset localPosition) {
    TextLayer? hitLayer;
    for (int i = textLayers.length - 1; i >= 0; i--) {
      final layer = textLayers[i];
      if ((localPosition - layer.position).distance < 50) {
        hitLayer = layer;
        break;
      }
    }

    if (hitLayer != null) {
      selectedTextLayerId.value = hitLayer.id;
      activeTool.value = StickerToolMode.text;
      brushMode.value = CanvasBrushMode.none;
    } else {
      selectedTextLayerId.value = null;
    }
  }

  @override
  void onClose() {
    selfieSegmenter.close();
    super.onClose();
  }
}

class _SegmentationParam {
  final String imagePath;
  final SelfieSegmenter selfieSegmenter;

  _SegmentationParam({
    required this.imagePath,
    required this.selfieSegmenter,
  });
}
