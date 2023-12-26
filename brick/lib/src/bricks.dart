import 'package:brick/brick.dart';
import 'package:brick/src/utils.dart';
import 'package:meta/meta.dart';

sealed class AnyBrick<T, R> {
  AnyBrick() {
    initialize();
  }

  late T _value;
  final Set<Callback<T>> _callbacks = {};
  int get listenerCount => _callbacks.length;

  T read();
  T get value;

  @protected
  R onRead();

  @protected
  @visibleForOverriding
  void onInitialize(T value) {}

  void reset();

  void addListener(Callback<T> callback) {
    _callbacks.add(callback);
  }

  void removeListener(Callback<T> callback) {
    _callbacks.remove(callback);
  }

  @protected
  void notifyListeners() {
    for (final callback in _callbacks.toSet()) {
      callback(_value);
    }
  }

  void listener(_) {
    reset();
  }

  @protected
  L listen<L>(Brick<L> brick) {
    brick.addListener(listener);
    return brick.read();
  }

  @protected
  L? listenNullable<L>(Brick<L>? brick) {
    brick?.addListener(listener);
    return brick?.read();
  }

  @protected
  void initialize();
}

// Sync ------------------------------------------------------------------------

abstract class Brick<T> extends AnyBrick<T, T> {
  Brick();

  factory Brick.functional(T Function(BrickHandle) onRead) {
    return BrickImpl(onRead);
  }

  @override
  T read() {
    return _value;
  }

  @override
  T get value => read();

  @override
  void reset() {
    _value = onRead();
    notifyListeners();
  }

  @override
  void initialize() {
    _value = onRead();
    onInitialize(_value);
    notifyListeners();
  }
}

const brick = Brick.functional;

abstract class MutableBrick<T> extends Brick<T> {
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

const mutableBrick = MutableBrick.functional;

// Impl

class BrickImpl<T> extends Brick<T> {
  BrickImpl(this._onRead);

  final T Function(BrickHandle) _onRead;

  @override
  T onRead() {
    return _onRead(BrickHandle(listener, []));
  }
}

class MutableBrickImpl<T> extends MutableBrick<T> {
  MutableBrickImpl(this._onRead, this._onUpdate);

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

abstract class AsyncBrick<T> extends AnyBrick<AsyncValue<T>, Future<T>> {
  AsyncBrick() {
    _value = AsyncValue.loading();
  }

  AsyncBrick.injected(T value) {
    _value = AsyncValue.data(value);
    onInitialize(_value);
  }

  late Future<T> _futureValue;

  @override
  AsyncValue<T> read() {
    return _value;
  }

  @override
  AsyncValue<T> get value => read();

  Future<T> readFuture() {
    return _futureValue;
  }

  @override
  void reset() {
    _value = AsyncValue.loading();
    notifyListeners();
    _futureValue = onRead();
    _futureValue.then((value) {
      _value = AsyncValue.data(value);
      notifyListeners();
    });
  }

  @override
  void initialize() {
    _futureValue = onRead();
    _futureValue.then((value) {
      _value = AsyncValue.data(value);
      notifyListeners();
    });
  }
}

abstract class AsyncMutableBrick<T> extends AsyncBrick<T> {
  AsyncMutableBrick();

  Future<T> onUpdate(T newValue);

  void update(T newValue) {
    _value = AsyncValue.loading();
    notifyListeners();
    onUpdate(newValue).then((value) {
      _value = AsyncValue.data(value);
      notifyListeners();
    });
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
      _value = AsyncValue.data(value);
      notifyListeners();
    });
    super.onInitialize(value);
  }
}
