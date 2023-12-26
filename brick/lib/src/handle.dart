import 'package:brick/brick.dart';

class BrickHandle {
  const BrickHandle(this.listener, this._bricks);

  final void Function(dynamic) listener;
  final List<AnyBrick<dynamic, dynamic>> _bricks;

  int get length => _bricks.length;

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
