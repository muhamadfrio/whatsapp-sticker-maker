import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../data/model/brush_stroke.dart';
import '../data/model/sticker_item.dart';
import '../data/model/text_layer.dart';
import '../widget/sticker_canvas_widget.dart';

enum StickerToolMode { none, erase, restore, text, background }

class StickerMakerController extends GetxController {
  final ImagePicker imagePicker;
  final SelfieSegmenter selfieSegmenter;

  StickerMakerController({
    required this.imagePicker,
    required this.selfieSegmenter,
  });

  final GlobalKey canvasGlobalKey = GlobalKey();
  final RxBool isExporting = false.obs;
  static const MethodChannel _whatsappChannel =
      MethodChannel('com.rio.whatsappstickermaker/whatsapp');

  // Sticker pack slots state (3 slots required for WhatsApp export)
  final RxInt selectedIndex = 0.obs;
  final RxList<StickerItem> stickers = <StickerItem>[
    StickerItem(),
    StickerItem(),
    StickerItem(),
  ].obs;

  StickerItem get activeSticker => stickers[selectedIndex.value];

  // Images for active slot
  final Rxn<Uint8List> originalImageBytes = Rxn<Uint8List>();
  final Rxn<Uint8List> processedImageBytes = Rxn<Uint8List>();
  final Rxn<ui.Image> originalUiImage = Rxn<ui.Image>();
  final Rxn<ui.Image> processedUiImage = Rxn<ui.Image>();

  final RxBool isLoading = false.obs;

  // Background Removal State for active slot
  final RxBool isBackgroundRemoved = false.obs;
  final RxDouble backgroundSensitivity = 0.3.obs; // Threshold: 0.05 to 0.85
  List<double>? _cachedConfidences;
  int? _cachedMaskWidth;
  int? _cachedMaskHeight;
  String? _currentImagePath;

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

  void selectStickerSlot(int index) {
    if (index < 0 || index >= stickers.length) return;
    if (selectedIndex.value == index) return;

    _saveCurrentStateToActiveSticker();
    selectedIndex.value = index;
    _loadActiveStickerToState();
  }

  void _saveCurrentStateToActiveSticker() {
    final item = activeSticker;
    item.originalImageBytes = originalImageBytes.value;
    item.processedImageBytes = processedImageBytes.value;
    item.originalUiImage = originalUiImage.value;
    item.processedUiImage = processedUiImage.value;
    item.isBackgroundRemoved = isBackgroundRemoved.value;
    item.backgroundSensitivity = backgroundSensitivity.value;
    item.cachedConfidences = _cachedConfidences;
    item.cachedMaskWidth = _cachedMaskWidth;
    item.cachedMaskHeight = _cachedMaskHeight;
    item.currentImagePath = _currentImagePath;
    item.strokes = List.from(strokes);
    item.textLayers = List.from(textLayers);
  }

  void _loadActiveStickerToState() {
    final item = activeSticker;
    originalImageBytes.value = item.originalImageBytes;
    processedImageBytes.value = item.processedImageBytes;
    originalUiImage.value = item.originalUiImage;
    processedUiImage.value = item.processedUiImage;
    isBackgroundRemoved.value = item.isBackgroundRemoved;
    backgroundSensitivity.value = item.backgroundSensitivity;
    _cachedConfidences = item.cachedConfidences;
    _cachedMaskWidth = item.cachedMaskWidth;
    _cachedMaskHeight = item.cachedMaskHeight;
    _currentImagePath = item.currentImagePath;

    strokes.assignAll(item.strokes);
    textLayers.assignAll(item.textLayers);

    selectedTextLayerId.value = null;
    activeTool.value = StickerToolMode.none;
    brushMode.value = CanvasBrushMode.none;

    stickers.refresh();
  }

  void clearStickerSlot(int index) {
    if (index < 0 || index >= stickers.length) return;
    stickers[index].reset();
    if (selectedIndex.value == index) {
      _loadActiveStickerToState();
    } else {
      stickers.refresh();
    }
  }

  Future<void> pickImageAndRemoveBackground() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      isLoading.value = true;
      resetState();

      _currentImagePath = pickedFile.path;
      final origBytes = await File(pickedFile.path).readAsBytes();
      originalImageBytes.value = origBytes;
      final origUiImg = await _bytesToUiImage(origBytes);
      originalUiImage.value = origUiImg;

      // Show original image as-is initially
      processedImageBytes.value = origBytes;
      processedUiImage.value = origUiImg;
      isBackgroundRemoved.value = false;

      _saveCurrentStateToActiveSticker();
      stickers.refresh();

      // Asynchronously extract ML Kit mask for optional background removal
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final mask = await selfieSegmenter.processImage(inputImage);

      if (mask != null) {
        _cachedConfidences = mask.confidences;
        _cachedMaskWidth = mask.width;
        _cachedMaskHeight = mask.height;
        _saveCurrentStateToActiveSticker();
        stickers.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat gambar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBackgroundRemoval(bool enable) async {
    isBackgroundRemoved.value = enable;
    if (!enable) {
      if (originalImageBytes.value != null && originalUiImage.value != null) {
        processedImageBytes.value = originalImageBytes.value;
        processedUiImage.value = originalUiImage.value;
      }
      _saveCurrentStateToActiveSticker();
      stickers.refresh();
    } else {
      await updateBackgroundRemoval();
    }
  }

  Future<void> setBackgroundSensitivity(double value) async {
    backgroundSensitivity.value = value;
    if (isBackgroundRemoved.value) {
      await updateBackgroundRemoval();
    } else {
      _saveCurrentStateToActiveSticker();
      stickers.refresh();
    }
  }

  Future<void> updateBackgroundRemoval() async {
    if (_currentImagePath == null ||
        _cachedConfidences == null ||
        _cachedMaskWidth == null ||
        _cachedMaskHeight == null) {
      return;
    }

    try {
      isLoading.value = true;
      final resultBytes = await compute(
        _applyMaskToImage,
        _MaskProcessingParam(
          imagePath: _currentImagePath!,
          maskWidth: _cachedMaskWidth!,
          maskHeight: _cachedMaskHeight!,
          confidences: _cachedConfidences!,
          threshold: backgroundSensitivity.value,
        ),
      );

      if (resultBytes != null) {
        final uiImg = await _bytesToUiImage(resultBytes);
        processedUiImage.value = uiImg;
        processedImageBytes.value = resultBytes;
        _saveCurrentStateToActiveSticker();
        stickers.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memproses hapus background: ${e.toString()}',
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
    isBackgroundRemoved.value = false;
    backgroundSensitivity.value = 0.3;
    _cachedConfidences = null;
    _cachedMaskWidth = null;
    _cachedMaskHeight = null;
    _currentImagePath = null;
    activeSticker.reset();
    stickers.refresh();
  }

  static Future<Uint8List?> _applyMaskToImage(_MaskProcessingParam param) async {
    final imageBytes = await File(param.imagePath).readAsBytes();
    img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    decodedImage = img.bakeOrientation(decodedImage);

    final resizedImage = img.copyResize(
      decodedImage,
      width: param.maskWidth,
      height: param.maskHeight,
    );

    final transparentImage = img.Image(
      width: param.maskWidth,
      height: param.maskHeight,
      numChannels: 4,
    );

    final confidences = param.confidences;
    final threshold = param.threshold;

    for (int y = 0; y < param.maskHeight; y++) {
      for (int x = 0; x < param.maskWidth; x++) {
        final index = y * param.maskWidth + x;
        final confidence = confidences[index];
        final pixel = resizedImage.getPixel(x, y);

        if (confidence > threshold) {
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
      activeSticker.strokes = List.from(strokes);
      stickers.refresh();
    }
  }

  void clearStrokes() {
    strokes.clear();
    activeSticker.strokes.clear();
    stickers.refresh();
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
    activeSticker.textLayers = List.from(textLayers);
    stickers.refresh();
  }

  void updateSelectedText(String text) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.text = text;
      textLayers.refresh();
      activeSticker.textLayers = List.from(textLayers);
      stickers.refresh();
    }
  }

  void updateSelectedTextColor(Color color) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.color = color;
      textLayers.refresh();
      activeSticker.textLayers = List.from(textLayers);
      stickers.refresh();
    }
  }

  void updateSelectedTextStrokeColor(Color color) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.strokeColor = color;
      textLayers.refresh();
      activeSticker.textLayers = List.from(textLayers);
      stickers.refresh();
    }
  }

  void updateSelectedTextStrokeWidth(double width) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.strokeWidth = width;
      textLayers.refresh();
      activeSticker.textLayers = List.from(textLayers);
      stickers.refresh();
    }
  }

  void updateSelectedTextFontFamily(String fontFamily) {
    final layer = selectedTextLayer;
    if (layer != null) {
      layer.fontFamily = fontFamily;
      textLayers.refresh();
      activeSticker.textLayers = List.from(textLayers);
      stickers.refresh();
    }
  }

  void removeSelectedTextLayer() {
    if (selectedTextLayerId.value != null) {
      textLayers.removeWhere((l) => l.id == selectedTextLayerId.value);
      selectedTextLayerId.value = null;
      activeSticker.textLayers = List.from(textLayers);
      stickers.refresh();
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
      activeSticker.textLayers = List.from(textLayers);
      stickers.refresh();
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
      activeSticker.strokes = List.from(strokes);
      stickers.refresh();
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

  Future<Uint8List> _renderStickerToWebp(StickerItem item) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    canvas.scale(512 / 320, 512 / 320);

    final painter = StickerCanvasPainter(
      originalImage: item.originalUiImage,
      processedImage: item.processedUiImage,
      strokes: item.strokes,
      textLayers: item.textLayers,
      brushSize: 0,
      brushMode: CanvasBrushMode.none,
      isExporting: true,
    );

    painter.paint(canvas, const Size(320, 320));

    final picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(512, 512);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Gagal mengonversi stiker ke data PNG.');
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    final img.Image? decoded = img.decodePng(pngBytes);
    if (decoded == null) {
      throw Exception('Gagal memproses gambar PNG stiker.');
    }

    img.Image sticker512;
    if (decoded.width == 512 && decoded.height == 512) {
      sticker512 = decoded;
    } else {
      sticker512 = img.Image(width: 512, height: 512, numChannels: 4);

      int targetWidth = 512;
      int targetHeight = 512;
      if (decoded.width > decoded.height) {
        targetHeight = (decoded.height * 512 / decoded.width).round();
      } else if (decoded.height > decoded.width) {
        targetWidth = (decoded.width * 512 / decoded.height).round();
      }

      final resized = img.copyResize(
        decoded,
        width: targetWidth,
        height: targetHeight,
      );
      final offsetX = (512 - targetWidth) ~/ 2;
      final offsetY = (512 - targetHeight) ~/ 2;
      img.compositeImage(sticker512, resized, dstX: offsetX, dstY: offsetY);
    }

    final Uint8List cleanPngBytes =
        Uint8List.fromList(img.encodePng(sticker512));

    int quality = 80;
    Uint8List? webpBytes = await FlutterImageCompress.compressWithList(
      cleanPngBytes,
      format: CompressFormat.webp,
      quality: quality,
      minWidth: 512,
      minHeight: 512,
    );

    while (webpBytes != null &&
        webpBytes.lengthInBytes > 95 * 1024 &&
        quality > 20) {
      quality -= 10;
      webpBytes = await FlutterImageCompress.compressWithList(
        cleanPngBytes,
        format: CompressFormat.webp,
        quality: quality,
        minWidth: 512,
        minHeight: 512,
      );
    }

    if (webpBytes == null || webpBytes.lengthInBytes > 100 * 1024) {
      throw Exception(
        'Ukuran file WebP melebihi batas 100 KB (${((webpBytes?.lengthInBytes ?? 0) / 1024).toStringAsFixed(1)} KB).',
      );
    }

    return webpBytes;
  }

  Future<Uint8List> _renderStickerToTrayPng(StickerItem item) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    canvas.scale(512 / 320, 512 / 320);

    final painter = StickerCanvasPainter(
      originalImage: item.originalUiImage,
      processedImage: item.processedUiImage,
      strokes: item.strokes,
      textLayers: item.textLayers,
      brushSize: 0,
      brushMode: CanvasBrushMode.none,
      isExporting: true,
    );

    painter.paint(canvas, const Size(320, 320));

    final picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(512, 512);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Gagal mengonversi icon tray.');
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final img.Image? decoded = img.decodePng(pngBytes);
    if (decoded == null) {
      throw Exception('Gagal memproses PNG icon tray.');
    }

    final img.Image trayImage = img.copyResize(decoded, width: 96, height: 96);
    return Uint8List.fromList(img.encodePng(trayImage, level: 9));
  }

  Future<void> exportAndSendToWhatsApp() async {
    _saveCurrentStateToActiveSticker();

    final filledCount = stickers.where((s) => s.hasImage).length;
    if (filledCount < 3) {
      Get.snackbar(
        'Stiker Belum Lengkap',
        'WhatsApp memerlukan minimal 3 gambar stiker dalam satu paket. Saat ini baru $filledCount/3 stiker.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade900,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      isExporting.value = true;

      final String? filesDirPath =
          await _whatsappChannel.invokeMethod<String>('getFilesDir');
      if (filesDirPath == null) {
        throw Exception('Gagal mendapatkan direktori file aplikasi.');
      }

      final stickerPacksParentDir = Directory('$filesDirPath/sticker_packs');
      if (await stickerPacksParentDir.exists()) {
        await for (final entity in stickerPacksParentDir.list()) {
          if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        }
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final packId = 'pack_$timestamp';
      final packName = 'Stiker Saya ${timestamp % 1000}';
      final packDir = Directory('$filesDirPath/sticker_packs/$packId');

      if (await packDir.exists()) {
        await packDir.delete(recursive: true);
      }
      await packDir.create(recursive: true);

      final configFile = File('${packDir.path}/config.txt');
      await configFile.writeAsString(
        '$packName\nRio Sticker Maker\n0\n1',
      );

      // Render tray icon from sticker 0
      final Uint8List trayPngBytes = await _renderStickerToTrayPng(stickers[0]);
      final trayFile = File('${packDir.path}/tray.png');
      await trayFile.writeAsBytes(trayPngBytes);

      // Render 3 WebP stickers
      for (int i = 0; i < 3; i++) {
        final webpBytes = await _renderStickerToWebp(stickers[i]);
        final stickerFile = File('${packDir.path}/$i.webp');
        await stickerFile.writeAsBytes(webpBytes);
      }

      await _whatsappChannel.invokeMethod('addStickerPack', {
        'identifier': packId,
        'name': packName,
      });

      Get.snackbar(
        'Sukses',
        '3 Stiker berhasil diekspor dan dikirim ke WhatsApp!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      final String message = 'Gagal mengekspor stiker: ${e.toString()}';
      debugPrint(message);
      Get.snackbar(
        'Error Export',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    selfieSegmenter.close();
    super.onClose();
  }
}

class _MaskProcessingParam {
  final String imagePath;
  final int maskWidth;
  final int maskHeight;
  final List<double> confidences;
  final double threshold;

  _MaskProcessingParam({
    required this.imagePath,
    required this.maskWidth,
    required this.maskHeight,
    required this.confidences,
    required this.threshold,
  });
}
