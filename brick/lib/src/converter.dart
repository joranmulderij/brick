import 'package:brick/brick.dart';

class AsyncConverterBrick<F, T> extends AsyncBrick<T> {
  AsyncConverterBrick(
    this._brick, {
    required this.from,
    required this.to,
  });

  final AsyncBrick<F> _brick;
  final T Function(F) from;
  final F Function(T) to;

  @override
  Future<T> onRead() {
    return _brick.read().futureValue.then(from);
  }

  @override
  void reset() {
    _brick.reset();
    super.reset();
  }
}

class AsyncMutableConverterBrick<F, T> extends AsyncMutableBrick<T> {
  AsyncMutableConverterBrick(
    this._brick, {
    required this.from,
    required this.to,
  });

  final AsyncMutableBrick<F> _brick;
  final T Function(F) from;
  final F Function(T) to;

  @override
  Future<T> onRead() {
    return _brick.read().futureValue.then(from);
  }

  @override
  Future<T> onUpdate(T newValue) {
    return _brick.onUpdate(to(newValue)).then(from);
  }
}

extension AsyncMutableBrickConverterExtension<F> on AsyncMutableBrick<F> {
  AsyncMutableConverterBrick<F, T> converted<T>({
    required T Function(F) from,
    required F Function(T) to,
  }) =>
      AsyncMutableConverterBrick<F, T>(this, from: from, to: to);
}

extension AsyncBrickConverterExtension<F> on AsyncBrick<F> {
  AsyncConverterBrick<F, T> converted<T>({
    required T Function(F) from,
    required F Function(T) to,
  }) =>
      AsyncConverterBrick<F, T>(this, from: from, to: to);
}
