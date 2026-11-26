import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class StickerMakerController extends GetxController {
  final ImagePicker imagePicker;
  final SelfieSegmenter selfieSegmenter;

  StickerMakerController({
    required this.imagePicker,
    required this.selfieSegmenter,
  });

  final Rxn<Uint8List> processedImageBytes = Rxn<Uint8List>();
  final RxBool isLoading = false.obs;

  Future<void> pickImageAndRemoveBackground() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      isLoading.value = true;

      final resultBytes = await compute(
        _processSegmentation,
        _SegmentationParam(
          imagePath: pickedFile.path,
          selfieSegmenter: selfieSegmenter,
        ),
      );

      if (resultBytes != null) {
        processedImageBytes.value = resultBytes;
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
