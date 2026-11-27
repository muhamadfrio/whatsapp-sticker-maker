import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/sticker_maker_controller.dart';
import '../data/model/brush_stroke.dart';
import 'sticker_canvas_widget.dart';

class StickerSelectorWidget extends StatelessWidget {
  final StickerMakerController controller;

  const StickerSelectorWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;
      final stickers = controller.stickers;
      final filledCount = stickers.where((s) => s.hasImage).length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Stiker Paket',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: filledCount == 3
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$filledCount/3 Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: filledCount == 3
                          ? Colors.green.shade800
                          : Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isSelected = selectedIndex == index;
              final item = stickers[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: GestureDetector(
                  onTap: () {
                    if (isSelected && !item.hasImage) {
                      controller.pickImageAndRemoveBackground();
                    } else {
                      controller.selectStickerSlot(index);
                      if (!item.hasImage) {
                        controller.pickImageAndRemoveBackground();
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 95,
                    height: 115,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurple.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.deepPurple.withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (item.hasImage) ...[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey.shade100,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: SizedBox(
                                            width: 320,
                                            height: 320,
                                            child: CustomPaint(
                                              painter: StickerCanvasPainter(
                                                originalImage:
                                                    item.originalUiImage,
                                                processedImage:
                                                    item.processedUiImage,
                                                strokes: item.strokes,
                                                textLayers: item.textLayers,
                                                brushSize: 0,
                                                brushMode: CanvasBrushMode.none,
                                                isExporting: false,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stiker ${index + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.deepPurple
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 32,
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Stiker ${index + 1}\n+ Tambah',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.deepPurple
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (item.hasImage)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: InkWell(
                              onTap: () => controller.clearStickerSlot(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}
