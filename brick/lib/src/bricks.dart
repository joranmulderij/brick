import 'package:brick/src/async_value.dart';
import 'package:brick/src/utils.dart';
import 'package:meta/meta.dart';

sealed class AnyBrick<T, R> {
  AnyBrick();

  late T _value;
  bool _initialized = false;
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
    if (!_initialized) initialize();
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

  factory Brick.functional(T Function() onRead) {
    return BrickImpl(onRead);
  }

  @override
  T read() {
    if (!_initialized) initialize();
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
    _initialized = true;
    onInitialize(_value);
    notifyListeners();
  }
}

const brick = MutableBrick.functional;

abstract class MutableBrick<T> extends Brick<T> {
  MutableBrick();

  factory MutableBrick.functional(
    T Function() onRead, [
    T Function(T newValue)? onUpdate,
  ]) {
    return MutableBrickImpl(onRead, onUpdate);
  }

  @override
  T read() {
    if (!_initialized) initialize();
    return _value;
  }

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

  final T Function() _onRead;

  @override
  T onRead() {
    return _onRead();
  }
}

class MutableBrickImpl<T> extends MutableBrick<T> {
  MutableBrickImpl(this._onRead, this._onUpdate);

  final T Function() _onRead;
  final T Function(T newValue)? _onUpdate;

  @override
  T onRead() {
    return _onRead();
  }

  @override
  T onUpdate(T newValue) {
    return _onUpdate?.call(newValue) ?? newValue;
  }
}

// Async -----------------------------------------------------------------------

abstract class AsyncBrick<T> extends AnyBrick<AsyncValue<T>, Future<T>> {
  AsyncBrick() {
    _value = AsyncValue.loading();
  }

  AsyncBrick.injected(T value) {
    _value = AsyncValue.data(value);
    _initialized = true;
    onInitialize(_value);
  }

  late Future<T> _futureValue;

  @override
  AsyncValue<T> read() {
    if (!_initialized) initialize();
    return _value;
  }

  @override
  AsyncValue<T> get value => read();

  Future<T> readFuture() {
    if (!_initialized) initialize();
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
    _initialized = true;
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
