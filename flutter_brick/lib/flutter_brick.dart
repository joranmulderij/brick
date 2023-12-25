import 'package:brick/brick.dart';
import 'package:flutter/widgets.dart';

class WidgetHandle {
  const WidgetHandle(this.listener, this._bricks);

  final void Function(dynamic) listener;
  final List<AnyBrick> _bricks;

  T listen<T, R>(AnyBrick<T, R> brick) {
    brick.addListener(listener);
    _bricks.add(brick);
    return brick.read();
  }

  T? listenNullable<T, R>(AnyBrick<T, R>? brick) {
    if (brick == null) return null;
    brick.addListener(listener);
    _bricks.add(brick);
    return brick.read();
  }
}

abstract class BrickConsumerWidget extends Widget {
  const BrickConsumerWidget({super.key});

  @override
  Element createElement() => _BrickConsumerElement(this);

  /// Builds the [Widget] using the supplied [context] and [use].
  @protected
  Widget build(BuildContext context, WidgetHandle handle);
}

class _BrickConsumerElement extends ComponentElement {
  _BrickConsumerElement(BrickConsumerWidget super.widget);

  final List<AnyBrick> _bricks = [];

  void listener(_) {
    markNeedsBuild();
  }

  @override
  Widget build() {
    final consumer = super.widget as BrickConsumerWidget;
    return consumer.build(
      this,
      WidgetHandle(listener, _bricks),
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
