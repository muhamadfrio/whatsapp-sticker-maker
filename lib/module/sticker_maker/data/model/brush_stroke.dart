import 'package:flutter/material.dart';

enum CanvasBrushMode { none, erase, restore }

class BrushStroke {
  final List<Offset> points;
  final double size;
  final CanvasBrushMode mode;

  BrushStroke({
    required this.points,
    required this.size,
    required this.mode,
  });
}
