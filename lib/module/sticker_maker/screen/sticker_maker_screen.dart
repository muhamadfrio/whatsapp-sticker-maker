import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsappstickermaker/common/theme/app_theme.dart';
import 'package:whatsappstickermaker/common/widgets/custom_appbar.dart';
import 'package:whatsappstickermaker/common/widgets/loading_widget.dart';
import 'package:whatsappstickermaker/common/widgets/safe_area_scaffold.dart';
import 'package:whatsappstickermaker/module/sticker_maker/controller/sticker_maker_controller.dart';
import 'package:whatsappstickermaker/module/sticker_maker/widget/sticker_canvas_widget.dart';
import 'package:whatsappstickermaker/module/sticker_maker/widget/sticker_editor_toolbar.dart';
import 'package:whatsappstickermaker/module/sticker_maker/widget/sticker_selector_widget.dart';

class StickerMakerScreen extends GetView<StickerMakerController> {
  const StickerMakerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: const CustomAppBar(
        title: 'Sticker Maker',
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: StickerCanvasWidget(
                          controller: controller,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        final filledCount = controller.stickers
                            .where((s) => s.hasImage)
                            .length;
                        final hasAnyImage = filledCount > 0;
                        final hasProcessedImage =
                            controller.processedImageBytes.value != null;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            CupertinoButton.filled(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              onPressed: () =>
                                  controller.pickImageAndRemoveBackground(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasProcessedImage
                                        ? CupertinoIcons.arrow_2_squarepath
                                        : CupertinoIcons.photo_fill_on_rectangle_fill,
                                    size: 18,
                                    color: CupertinoColors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    hasProcessedImage
                                        ? 'Ganti Gambar (${controller.selectedIndex.value + 1})'
                                        : 'Pilih Gambar (${controller.selectedIndex.value + 1})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: CupertinoColors.white
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasAnyImage)
                              CupertinoButton(
                                color: filledCount == 3
                                    ? AppTheme.systemGreen
                                    : AppTheme.systemGreen.withOpacity(0.75),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                onPressed: () =>
                                    controller.exportAndSendToWhatsApp(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.paperplane_fill,
                                      size: 18,
                                      color: CupertinoColors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kirim ke WhatsApp ($filledCount/3)',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      StickerSelectorWidget(controller: controller),
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
