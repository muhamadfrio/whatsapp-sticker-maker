import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsappstickermaker/common/theme/app_theme.dart';
import 'package:whatsappstickermaker/module/sticker_maker/controller/sticker_maker_controller.dart';
import 'package:whatsappstickermaker/module/sticker_maker/data/model/brush_stroke.dart';
import 'package:whatsappstickermaker/module/sticker_maker/widget/sticker_canvas_widget.dart';

class StickerSelectorWidget extends StatelessWidget {
  final StickerMakerController controller;

  const StickerSelectorWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;
      final stickers = controller.stickers;
      final filledCount = stickers.where((s) => s.hasImage).length;
      final isComplete = filledCount == 3;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Stiker Paket',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: isDark ? AppTheme.darkLabel : AppTheme.label,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? AppTheme.systemGreen.withOpacity(0.15)
                        : AppTheme.systemOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$filledCount/3 Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isComplete
                          ? AppTheme.systemGreen
                          : AppTheme.systemOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isSelected = selectedIndex == index;
              final item = stickers[index];

              final cardBg = isSelected
                  ? AppTheme.primary.withOpacity(0.08)
                  : (isDark
                      ? AppTheme.darkSecondarySystemGroupedBackground
                      : AppTheme.secondarySystemGroupedBackground);

              final borderColor = isSelected
                  ? AppTheme.primary
                  : (isDark ? const Color(0x38FFFFFF) : const Color(0x1F000000));

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
                    width: 98,
                    height: 118,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2.0 : 0.8,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (item.hasImage) ...[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: isDark
                                            ? const Color(0x1FAFAFEB)
                                            : const Color(0x0F000000),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
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
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTheme.primary
                                          : (isDark
                                              ? AppTheme.darkSecondaryLabel
                                              : AppTheme.secondaryLabel),
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    CupertinoIcons.plus_circle_fill,
                                    size: 32,
                                    color: isSelected
                                        ? AppTheme.primary
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.black26),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Stiker ${index + 1}\n+ Tambah',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTheme.primary
                                          : (isDark
                                              ? AppTheme.darkSecondaryLabel
                                              : AppTheme.secondaryLabel),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(100),
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
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.clearStickerSlot(index),
                              child: const Icon(
                                CupertinoIcons.xmark_circle_fill,
                                size: 18,
                                color: AppTheme.systemRed,
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
