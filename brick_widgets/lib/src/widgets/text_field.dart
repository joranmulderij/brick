import 'package:brick/brick.dart';
import 'package:brick_widgets/src/bricks/text_editing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brick/flutter_brick.dart';

class BrickTextField extends BrickConsumerWidget {
  BrickTextField(this.textBrick, {super.key})
      : _controllerBrick = TextEditingControllerBrick(textBrick);

  final MutableBrick<String> textBrick;
  final TextEditingControllerBrick _controllerBrick;

  @override
  Widget build(BuildContext context, WidgetHandle handle) {
    return TextField(
      controller: _controllerBrick.read(),
    );
  }
}
