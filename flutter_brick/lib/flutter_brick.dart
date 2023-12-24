import 'package:brick/brick.dart';
import 'package:flutter/widgets.dart';

abstract class BrickConsumerWidget extends Widget {
  const BrickConsumerWidget({super.key});

  @override
  Element createElement() => _BrickConsumerElement(this);

  /// Builds the [Widget] using the supplied [context] and [use].
  @protected
  Widget build(BuildContext context, L Function<L>(Brick<L> brick) listen);
}

class _BrickConsumerElement extends ComponentElement {
  _BrickConsumerElement(BrickConsumerWidget super.widget);

  final List<Brick> _bricks = [];

  void listener(_) {
    markNeedsBuild();
  }

  L listen<L>(Brick<L> brick) {
    brick.addListener(listener);
    _bricks.add(brick);
    return brick.read();
  }

  @override
  Widget build() {
    final consumer = super.widget as BrickConsumerWidget;
    return consumer.build(
      this,
      listen,
    );
  }

  @override
  void unmount() {
    for (final brick in _bricks) {
      brick.removeListener(listener);
    }
    super.unmount();
  }
}
