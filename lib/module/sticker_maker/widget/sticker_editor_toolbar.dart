import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsappstickermaker/common/theme/app_theme.dart';
import 'package:whatsappstickermaker/module/sticker_maker/controller/sticker_maker_controller.dart';
import 'package:whatsappstickermaker/module/sticker_maker/data/model/brush_stroke.dart';

class StickerEditorToolbar extends StatelessWidget {
  final StickerMakerController controller;

  const StickerEditorToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final activeTool = controller.activeTool.value;

      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xD91C1C1E)
                  : const Color(0xFAF9F9F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0x38FFFFFF) : const Color(0x29000000),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Grab Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 1. Tool Selection Row
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildToolChip(
                              icon: CupertinoIcons.sparkles,
                              label: 'Hapus BG',
                              isActive: activeTool == StickerToolMode.background,
                              onTap: () =>
                                  controller.selectTool(StickerToolMode.background),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildToolChip(
                              icon: CupertinoIcons.scissors,
                              label: 'Eraser',
                              isActive: activeTool == StickerToolMode.erase,
                              onTap: () =>
                                  controller.selectTool(StickerToolMode.erase),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildToolChip(
                              icon: CupertinoIcons.arrow_counterclockwise,
                              label: 'Restore',
                              isActive: activeTool == StickerToolMode.restore,
                              onTap: () =>
                                  controller.selectTool(StickerToolMode.restore),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildToolChip(
                              icon: CupertinoIcons.textformat,
                              label: 'Teks',
                              isActive: activeTool == StickerToolMode.text,
                              onTap: () =>
                                  controller.selectTool(StickerToolMode.text),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    CupertinoButton(
                      padding: const EdgeInsets.all(6),
                      onPressed: () {
                        controller.activeTool.value = StickerToolMode.none;
                        controller.brushMode.value = CanvasBrushMode.none;
                        controller.selectedTextLayerId.value = null;
                      },
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 24,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 2. Active Tool Controls
                if (activeTool == StickerToolMode.background)
                  _buildBackgroundControls(context, isDark),
                if (activeTool == StickerToolMode.erase ||
                    activeTool == StickerToolMode.restore)
                  _buildBrushControls(context, isDark),
                if (activeTool == StickerToolMode.text)
                  _buildTextControls(context, isDark),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildToolChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary
              : (isDark ? const Color(0x2E767680) : const Color(0x1F767680)),
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(
                  color: isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000),
                  width: 0.5,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? AppTheme.darkLabel : AppTheme.label),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? AppTheme.darkLabel : AppTheme.label),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundControls(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.sparkles,
                  size: 18,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hapus Background Auto:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Obx(
              () => CupertinoSwitch(
                value: controller.isBackgroundRemoved.value,
                activeColor: AppTheme.primary,
                onChanged: (val) => controller.toggleBackgroundRemoval(val),
              ),
            ),
          ],
        ),
        Obx(() {
          if (!controller.isBackgroundRemoved.value) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Sensitivitas Pemotongan:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(controller.backgroundSensitivity.value * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlider(
                  value: controller.backgroundSensitivity.value,
                  min: 0.05,
                  max: 0.85,
                  divisions: 16,
                  activeColor: AppTheme.primary,
                  onChangeEnd: (val) => controller.setBackgroundSensitivity(val),
                  onChanged: (val) {
                    controller.backgroundSensitivity.value = val;
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBrushControls(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.paintbrush_fill,
              size: 18,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Ukuran Kuas:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Expanded(
              child: CupertinoSlider(
                value: controller.brushSize.value,
                min: 5.0,
                max: 60.0,
                activeColor: AppTheme.primary,
                onChanged: (val) => controller.setBrushSize(val),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: Center(
                child: Container(
                  width: (controller.brushSize.value / 60.0) * 18,
                  height: (controller.brushSize.value / 60.0) * 18,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onPressed: () => controller.undoLastStroke(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.arrow_uturn_left,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Undo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onPressed: () => controller.clearStrokes(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.trash,
                    size: 16,
                    color: AppTheme.systemRed,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Reset Kuas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.systemRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextControls(BuildContext context, bool isDark) {
    final selectedLayer = controller.selectedTextLayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              borderRadius: BorderRadius.circular(12),
              onPressed: () => _showAddTextDialog(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.plus, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Tambah Teks',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (selectedLayer != null)
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                onPressed: () => controller.removeSelectedTextLayer(),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: AppTheme.systemRed,
                  size: 20,
                ),
              ),
          ],
        ),
        if (selectedLayer != null) ...[
          const SizedBox(height: 10),
          Text(
            'Pilih Font:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: controller.fontOptions.map((font) {
                final isSelected = selectedLayer.fontFamily == font;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => controller.updateSelectedTextFontFamily(font),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark ? const Color(0x3D767680) : const Color(0x1F767680)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        font,
                        style: GoogleFonts.getFont(
                          font,
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Warna Teks:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: controller.colorOptions.map((color) {
                final isSelected = selectedLayer.color == color;
                return GestureDetector(
                  onTap: () => controller.updateSelectedTextColor(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                'Outline Teks:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoSlider(
                  value: selectedLayer.strokeWidth,
                  min: 0.0,
                  max: 12.0,
                  activeColor: AppTheme.primary,
                  onChanged: (val) =>
                      controller.updateSelectedTextStrokeWidth(val),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: controller.colorOptions.map((color) {
                final isSelected = selectedLayer.strokeColor == color;
                return GestureDetector(
                  onTap: () => controller.updateSelectedTextStrokeColor(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  void _showAddTextDialog(BuildContext context) {
    final textEditingController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Tambah Teks Stiker'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: textEditingController,
            autofocus: true,
            placeholder: 'Ketik teks stiker di sini...',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x3D767680) : const Color(0x1F767680),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            isDestructiveAction: true,
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              final text = textEditingController.text.trim();
              if (text.isNotEmpty) {
                controller.addTextLayer(text);
              }
              Navigator.of(ctx).pop();
            },
            isDefaultAction: true,
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
