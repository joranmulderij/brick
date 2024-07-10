import 'package:brick/src/utils.dart';

sealed class AnyBrick<T, R> {
  AnyBrick() {
    _initialize();
  }

  late T _value;

  final Set<Callback<T>> _callbacks = {};
  final Set<AnyBrick<dynamic, dynamic>> _bricksListeningTo = {};

  T get value => _value;

  void reset();

  void _initialize();

  // L listen<L>(Brick<L> brick) {
  //   brick.addListener(listener);
  //   return brick.read();
  // }

  // L? listenNullable<L>(Brick<L>? brick) {
  //   brick?.addListener(listener);
  //   return brick?.read();
  // }

  void addListener(Callback<T> callback) {
    _callbacks.add(callback);
  }

  void removeListener(Callback<T> callback) {
    _callbacks.remove(callback);
  }

  void _notifyListeners() {
    for (final callback in _callbacks.toSet()) {
      callback(_value);
    }
  }

  void _listener<T2>(T2 _) {
    reset();
  }

  void _listenToBrick<T2, R2>(AnyBrick<T2, R2> brick) {
    brick.addListener(_listener);
    _bricksListeningTo.add(brick);
  }

  void dispose() {
    for (final brick in _bricksListeningTo) {
      brick.removeListener(_listener);
    }
  }
}

// Sync ------------------------------------------------------------------------

class Brick<T> extends AnyBrick<T, T> {
  Brick(this._onRead);

  final T Function(BrickHandle<T, T> handle) _onRead;

  @override
  void reset() => _initialize();

  @override
  void _initialize() {
    _value = _onRead(BrickHandle(this));
    _notifyListeners();
  }
}

class MutableBrick<T> extends Brick<T> {
  MutableBrick(super._onRead);

  void update(T newValue) {
    _value = newValue;
    _notifyListeners();
  }
}

class BrickHandle<T, R> {
  const BrickHandle(this._brick);

  final AnyBrick<T, R> _brick;

  T2 call<T2, R2>(AnyBrick<T2, R2> brick) => listen(brick);

  T2 listen<T2, R2>(AnyBrick<T2, R2> brick) {
    _brick._listenToBrick(brick);
    return brick.value;
  }

  T2? listenNullable<T2, R2>(AnyBrick<T2, R2>? brick) {
    if (brick == null) return null;
    _brick._listenToBrick(brick);
    return brick.value;
  }
}


/*
const mutableBrick = MutableBrick.functional;

sealed class MutableBrick<T> extends Brick<T> {
  MutableBrick();

  factory MutableBrick.functional(
    T Function(BrickHandle) onRead, [
    T Function(BrickHandle, T newValue)? onUpdate,
  ]) {
    return MutableBrickImpl(onRead, onUpdate);
  }

  @override
  T read() {
    return _value;
  }

  // Not sure if this is a good idea.
  // set value(T newValue) => update(newValue);

  T onUpdate(T newValue);

  void update(T newValue) {
    final temp = _value;
    _value = onUpdate(newValue);
    if (temp == _value) return;
    notifyListeners();
  }
}

// Impl

class BrickImpl<T> extends Brick<T> {
  BrickImpl(this._onRead);

  @override
  T onRead() {
    return _onRead(BrickHandle(listener, []));
  }
}

class MutableBrickImpl<T> extends MutableBrick<T> {
  MutableBrickImpl(this._onRead, this._onUpdate);

  @override
  final T Function(BrickHandle) _onRead;
  final T Function(BrickHandle, T newValue)? _onUpdate;

  @override
  T onRead() {
    return _onRead(BrickHandle(listener, []));
  }

  @override
  T onUpdate(T newValue) {
    return _onUpdate?.call(BrickHandle(listener, []), newValue) ?? newValue;
  }
}

// Async -----------------------------------------------------------------------

const asyncBrick = AsyncBrick.functional;

abstract class AsyncBrick<T> extends AnyBrick<AsyncValue<T>, Future<T>> {
  AsyncBrick();

  factory AsyncBrick.functional(Future<T> Function(BrickHandle) onRead) {
    return AsyncBrickImpl(onRead);
  }

  AsyncBrick.injected(T value) {
    _value = AsyncValue.data(value, Future.value(value));
    onInitialize(_value);
  }

  @override
  AsyncValue<T> read() {
    return _value;
  }

  @override
  AsyncValue<T> get value => read();

  @override
  void reset() {
    final futureValue = onRead();
    _value = AsyncValue.loading(futureValue);
    notifyListeners();
    futureValue.then((value) {
      _value = AsyncValue.data(value, futureValue);
      notifyListeners();
    });
  }

  @override
  void initialize() {
    final futureValue = onRead();
    _value = AsyncValue.loading(futureValue);
    futureValue.then((value) {
      _value = AsyncValue.data(value, futureValue);
      onInitialize(_value);
      notifyListeners();
    });
  }
}

const asyncMutableBrick = AsyncMutableBrick.functional;

abstract class AsyncMutableBrick<T> extends AsyncBrick<T> {
  AsyncMutableBrick();

  factory AsyncMutableBrick.functional(
    Future<T> Function(BrickHandle) onRead, [
    Future<T> Function(BrickHandle, T newValue)? onUpdate,
  ]) {
    return AsyncMutableBrickImpl(onRead, onUpdate);
  }

  Future<T> onUpdate(T newValue);

  Future<void> update(T newValue) async {
    final futureValue = onUpdate(newValue);
    _value = AsyncValue.loading(futureValue);
    notifyListeners();
    await futureValue.then((value) {
      _value = AsyncValue.data(value, futureValue);
      notifyListeners();
    });
  }
}

// Impl ------------------------------------------------------------------------

class AsyncBrickImpl<T> extends AsyncBrick<T> {
  AsyncBrickImpl(this._onRead);

  final Future<T> Function(BrickHandle) _onRead;

  @override
  Future<T> onRead() {
    return _onRead(BrickHandle(listener, []));
  }
}

class AsyncMutableBrickImpl<T> extends AsyncMutableBrick<T> {
  AsyncMutableBrickImpl(this._onRead, this._onUpdate);

  final Future<T> Function(BrickHandle) _onRead;
  final Future<T> Function(BrickHandle, T newValue)? _onUpdate;

  @override
  Future<T> onRead() {
    return _onRead(BrickHandle(listener, []));
  }

  @override
  Future<T> onUpdate(T newValue) {
    return _onUpdate?.call(BrickHandle(listener, []), newValue) ??
        Future.value(newValue);
  }
}

// Stream ----------------------------------------------------------------------

class StreamBrick<T> extends AsyncBrick<T> {
  StreamBrick(this._stream);

  final Stream<T> _stream;

  @override
  Future<T> onRead() {
    return _stream.first;
  }

  @override
  void onInitialize(AsyncValue<T> value) {
    _stream.listen((value) {
      _value = AsyncValue.data(value, Future.value(value));
      notifyListeners();
    });
    super.onInitialize(value);
  }
}
*/