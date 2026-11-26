import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/appbar_miners.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../common/widgets/safe_area_scaffold.dart';
import '../controller/sticker_maker_controller.dart';
import '../widget/processed_image_preview.dart';

class StickerMakerScreen extends GetView<StickerMakerController> {
  const StickerMakerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: const AppbarMiners(
        title: 'Sticker Maker',
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => ProcessedImagePreview(
                      imageBytes: controller.processedImageBytes.value,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => controller.pickImageAndRemoveBackground(),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pilih Gambar dari Galeri'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? buildLoading(context)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
