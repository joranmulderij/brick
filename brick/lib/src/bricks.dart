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

  @protected
  R onRead();

  void reset();

  void addListener(Callback<T> callback) {
    initialize();
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
    initialize();
    return _value;
  }

  @override
  void reset() {
    _value = onRead();
    notifyListeners();
  }

  @override
  void initialize() {
    if (_initialized) return;
    _value = onRead();
    _initialized = true;
    notifyListeners();
  }
}

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
    initialize();
    return _value;
  }

  T onUpdate(T newValue);

  void update(T newValue) {
    _value = onUpdate(newValue);
    notifyListeners();
  }
}

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

  // factory AsyncBrick.functional(T Function() onRead) {
  //   return AsyncBrickImpl(onRead);
  // }

  @override
  AsyncValue<T> read() {
    initialize();
    return _value;
  }

  @override
  void reset() {
    _value = AsyncValue.loading();
    notifyListeners();
    onRead().then((value) {
      _value = AsyncValue.data(value);
      notifyListeners();
    });
  }

  @override
  void initialize() {
    if (_initialized) return;
    onRead().then((value) {
      _value = AsyncValue.data(value);
      notifyListeners();
    });
    _initialized = true;
  }
}

abstract class AsyncMutableBrick<T> extends AsyncBrick<T> {
  AsyncMutableBrick();

  // factory AsyncMutableBrick.functional(
  //   T Function() onRead, [
  //   T Function(T newValue)? onUpdate,
  // ]) {
  //   return AsyncMutableBrickImpl(onRead, onUpdate);
  // }

  @override
  AsyncValue<T> read() {
    initialize();
    return _value;
  }

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






// abstract class AsyncMutableBrick<T> extends AnyBrick<AsyncValue<T>, Future<T>> {
//   AsyncMutableBrick() {
//     _value = AsyncValue.loading();
//   }

//   @override
//   void notifyListeners() {
//     for (final callback in _callbacks) {
//       callback(_value);
//     }
//   }

//   Future<void> update(T newValue) async {
//     newValue = await onUpdate(newValue);
//     _value = AsyncValue.data(newValue);
//     notifyListeners();
//   }

//   @override
//   AsyncValue<T> read() {
//     if (!_initialized) {
//       onRead().then((value) {
//         _value = AsyncValue.data(value);
//         notifyListeners();
//       });
//       _initialized = true;
//     }
//     return _value;
//   }

//   // AsyncValue<T> get value => _value;

//   @override
//   Future<void> reset() async {
//     _value = AsyncValue.loading();
//     notifyListeners();
//     final newValue = await onRead();
//     _value = AsyncValue.data(newValue);
//     notifyListeners();
//   }

//   @protected
//   Future<T> onUpdate(T newValue);
// }
