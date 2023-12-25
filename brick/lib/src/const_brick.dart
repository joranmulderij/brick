import 'package:brick/brick.dart';
import 'package:brick/src/utils.dart';

const constBrick = ConstBrick.new;

class ConstBrick<T> implements Brick<T> {
  const ConstBrick(this.value);

  @override
  final T value;

  @override
  void addListener(Callback<T> callback) {}

  @override
  void initialize() {}

  @override
  L listen<L>(Brick<L> brick) => brick.value;

  @override
  L? listenNullable<L>(Brick<L>? brick) => brick?.value;

  @override
  void listener(_) {}

  @override
  int get listenerCount => 0;

  @override
  void notifyListeners() {}

  @override
  void onInitialize(T value) {}

  @override
  T onRead() => value;

  @override
  T read() => value;

  @override
  void removeListener(Callback<T> callback) {}

  @override
  void reset() {}
}
