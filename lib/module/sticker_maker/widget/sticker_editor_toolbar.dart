import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/sticker_maker_controller.dart';

class StickerEditorToolbar extends StatelessWidget {
  final StickerMakerController controller;

  const StickerEditorToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeTool = controller.activeTool.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Tool Selection Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolChip(
                  icon: Icons.cleaning_services_outlined,
                  label: 'Eraser',
                  isActive: activeTool == StickerToolMode.erase,
                  onTap: () => controller.selectTool(StickerToolMode.erase),
                ),
                _buildToolChip(
                  icon: Icons.restore_outlined,
                  label: 'Restore',
                  isActive: activeTool == StickerToolMode.restore,
                  onTap: () => controller.selectTool(StickerToolMode.restore),
                ),
                _buildToolChip(
                  icon: Icons.text_fields_outlined,
                  label: 'Teks',
                  isActive: activeTool == StickerToolMode.text,
                  onTap: () => controller.selectTool(StickerToolMode.text),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 2. Active Tool Controls
            if (activeTool == StickerToolMode.erase || activeTool == StickerToolMode.restore)
              _buildBrushControls(context),
            if (activeTool == StickerToolMode.text)
              _buildTextControls(context),
          ],
        ),
      );
    });
  }

  Widget _buildToolChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: isActive ? Colors.white : Colors.deepPurple,
      ),
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: Colors.deepPurple,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBrushControls(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.brush, size: 20, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text(
              'Ukuran Kuas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Expanded(
              child: Slider(
                value: controller.brushSize.value,
                min: 5.0,
                max: 60.0,
                activeColor: Colors.deepPurple,
                onChanged: (val) => controller.setBrushSize(val),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Center(
                child: Container(
                  width: (controller.brushSize.value / 60.0) * 18,
                  height: (controller.brushSize.value / 60.0) * 18,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => controller.undoLastStroke(),
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Undo'),
            ),
            TextButton.icon(
              onPressed: () => controller.clearStrokes(),
              icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
              label: const Text('Reset Kuas', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextControls(BuildContext context) {
    final selectedLayer = controller.selectedTextLayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddTextDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Teks'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const Spacer(),
            if (selectedLayer != null)
              IconButton(
                onPressed: () => controller.removeSelectedTextLayer(),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Hapus Teks',
              ),
          ],
        ),
        if (selectedLayer != null) ...[
          const SizedBox(height: 8),
          const Text(
            'Pilih Font:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.fontOptions.map((font) {
                final isSelected = selectedLayer.fontFamily == font;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      font,
                      style: GoogleFonts.getFont(
                        font,
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple,
                    onSelected: (_) => controller.updateSelectedTextFontFamily(font),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Warna Teks:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.colorOptions.map((color) {
                final isSelected = selectedLayer.color == color;
                return GestureDetector(
                  onTap: () => controller.updateSelectedTextColor(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Text(
                'Outline Teks:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: selectedLayer.strokeWidth,
                  min: 0.0,
                  max: 12.0,
                  activeColor: Colors.deepPurple,
                  onChanged: (val) => controller.updateSelectedTextStrokeWidth(val),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.colorOptions.map((color) {
                final isSelected = selectedLayer.strokeColor == color;
                return GestureDetector(
                  onTap: () => controller.updateSelectedTextStrokeColor(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Teks Stiker'),
        content: TextField(
          controller: textEditingController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ketik teks stiker di sini...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textEditingController.text.trim();
              if (text.isNotEmpty) {
                controller.addTextLayer(text);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
