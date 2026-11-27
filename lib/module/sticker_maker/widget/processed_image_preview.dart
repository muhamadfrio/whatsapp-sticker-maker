import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsappstickermaker/common/theme/app_theme.dart';

class ProcessedImagePreview extends StatelessWidget {
  final Uint8List? imageBytes;

  const ProcessedImagePreview({
    super.key,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageBytes == null) {
      return Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkSecondarySystemGroupedBackground
              : AppTheme.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0x38FFFFFF) : const Color(0x1F000000),
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.photo_on_rectangle,
              size: 56,
              color: isDark ? AppTheme.darkSecondaryLabel : AppTheme.secondaryLabel,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada gambar.\nPilih gambar dari galeri untuk membuat stiker.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.darkSecondaryLabel : AppTheme.secondaryLabel,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
