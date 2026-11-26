import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProcessedImagePreview extends StatelessWidget {
  final Uint8List? imageBytes;

  const ProcessedImagePreview({
    super.key,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null) {
      return Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Belum ada gambar.\nPilih gambar dari galeri untuk membuat stiker.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
