import 'package:brick/brick.dart';
import 'package:flutter/widgets.dart';

class BrickConsumer extends BrickConsumerWidget {
  const BrickConsumer({required this.builder, super.key});

  final Widget Function(BuildContext context, BrickHandle handle) builder;

  @override
  Widget build(BuildContext context, BrickHandle handle) {
    return builder(context, handle);
  }
}

abstract class BrickConsumerWidget extends Widget {
  const BrickConsumerWidget({super.key});

  @override
  Element createElement() => BrickConsumerElement(this);

  /// Builds the [Widget] using the supplied [context] and [use].
  @protected
  Widget build(BuildContext context, BrickHandle handle);
}

class BrickConsumerElement extends ComponentElement {
  BrickConsumerElement(BrickConsumerWidget super.widget);

  final List<AnyBrick> _bricks = [];

  void listener(_) {
    markNeedsBuild();
  }

  @override
  Widget build() {
    final consumer = super.widget as BrickConsumerWidget;
    return consumer.build(
      this,
      BrickHandle(listener, _bricks),
    );
  }

  @override
  void update(BrickConsumerWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    rebuild(force: true);
  }

  @override
  void unmount() {
    for (final brick in _bricks) {
      brick.removeListener(listener);
    }
    super.unmount();
  }
}
