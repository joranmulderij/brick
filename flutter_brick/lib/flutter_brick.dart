import 'package:brick/brick.dart';
import 'package:flutter/widgets.dart';

abstract class BrickConsumerWidget extends Widget {
  const BrickConsumerWidget({super.key});

  @override
  Element createElement() => _BrickConsumerElement(this);

  /// Builds the [Widget] using the supplied [context] and [use].
  @protected
  Widget build(
      BuildContext context, T Function<T, R>(AnyBrick<T, R> brick) listen);
}

class _BrickConsumerElement extends ComponentElement {
  _BrickConsumerElement(BrickConsumerWidget super.widget);

  final List<AnyBrick> _bricks = [];

  void listener(_) {
    markNeedsBuild();
  }

  T listen<T, R>(AnyBrick<T, R> brick) {
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
