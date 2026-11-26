import 'package:flutter/material.dart';

class TextLayer {
  final String id;
  String text;
  Offset position;
  double scale;
  Color color;
  Color strokeColor;
  double strokeWidth;
  String fontFamily;

  TextLayer({
    required this.id,
    required this.text,
    required this.position,
    this.scale = 1.0,
    this.color = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
    this.fontFamily = 'Poppins',
  });

  TextLayer copyWith({
    String? id,
    String? text,
    Offset? position,
    double? scale,
    Color? color,
    Color? strokeColor,
    double? strokeWidth,
    String? fontFamily,
  }) {
    return TextLayer(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
