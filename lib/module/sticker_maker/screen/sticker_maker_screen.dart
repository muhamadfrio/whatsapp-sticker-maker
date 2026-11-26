import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/appbar_miners.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../common/widgets/safe_area_scaffold.dart';
import '../controller/sticker_maker_controller.dart';
import '../widget/sticker_canvas_widget.dart';
import '../widget/sticker_editor_toolbar.dart';

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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: StickerCanvasWidget(
                          controller: controller,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => ElevatedButton.icon(
                          onPressed: () => controller.pickImageAndRemoveBackground(),
                          icon: Icon(
                            controller.processedImageBytes.value == null
                                ? Icons.photo_library
                                : Icons.published_with_changes,
                          ),
                          label: Text(
                            controller.processedImageBytes.value == null
                                ? 'Pilih Gambar dari Galeri'
                                : 'Ganti Gambar',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => controller.processedImageBytes.value != null
                    ? StickerEditorToolbar(controller: controller)
                    : const SizedBox.shrink(),
              ),
            ],
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
