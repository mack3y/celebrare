import 'package:flutter/material.dart';

class TextItem {
  final String id;
  String text;
  Offset position;
  String fontFamily;
  double fontSize;
  FontWeight fontWeight;
  FontStyle fontStyle;
  bool underline;
  bool lineThrough;
  Color color;

  TextItem({
    required this.id,
    required this.text,
    required this.position,
    this.fontFamily = 'Roboto',
    this.fontSize = 24,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.underline = false,
    this.lineThrough = false,
    this.color = Colors.black,
  });

  TextItem copyWith({
    String? text,
    Offset? position,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    bool? underline,
    bool? lineThrough,
    Color? color,
  }) {
    return TextItem(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      underline: underline ?? this.underline,
      lineThrough: lineThrough ?? this.lineThrough,
      color: color ?? this.color,
    );
  }

  TextDecoration get textDecoration {
    if (underline && lineThrough) {
      return TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]);
    } else if (underline) {
      return TextDecoration.underline;
    } else if (lineThrough) {
      return TextDecoration.lineThrough;
    }
    return TextDecoration.none;
  }
}
