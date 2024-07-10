import 'package:brick/brick.dart';
import 'package:flutter/material.dart';

/// A [Brick] that provides a [TextEditingController] to a [TextField].
class TextEditingControllerBrick extends Brick<TextEditingController> {
  TextEditingControllerBrick([this.initialTextBrick]);

  final MutableBrick<String>? initialTextBrick;

  @override
  TextEditingController onRead() {
    final initialText = initialTextBrick?.read();
    final controller = TextEditingController(text: initialText);
    return controller;
  }

  @override
  void onInitialize(value) {
    initialTextBrick?.addListener((newTextValue) {
      if (newTextValue == value.text) return;
      value.text = newTextValue;
    });
    value.addListener(() {
      initialTextBrick?.update(value.text);
    });
  }
}
