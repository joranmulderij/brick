import 'package:brick/brick.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Brick<T> useBrick<T>(T Function(BrickHandle handle) onRead) {
  return use(_BrickHook<T, Brick<T>>(onRead: onRead, brickBuilder: brick));
}

MutableBrick<T> useMutableBrick<T>(T Function(BrickHandle handle) onRead) {
  return use(_BrickHook<T, MutableBrick<T>>(
    onRead: onRead,
    brickBuilder: mutableBrick,
  ));
}

B useOtherBrick<T, B extends Brick<T>>(B brick) {
  return use(_BrickHook<T, B>(
    onRead: (handle) => brick.value, // return value never gets used
    brickBuilder: (onRead) => brick,
  ));
}

class _BrickHook<T, B extends Brick<T>> extends Hook<B> {
  const _BrickHook({required this.onRead, required this.brickBuilder});

  final T Function(BrickHandle handle) onRead;
  final B Function(T Function(BrickHandle)) brickBuilder;

  @override
  _BrickHookState<T, B> createState() => _BrickHookState<T, B>();
}

class _BrickHookState<T, B extends Brick<T>>
    extends HookState<B, _BrickHook<T, B>> {
  late final _state = hook.brickBuilder(hook.onRead)..addListener(_listener);

  @override
  void dispose() {
    // _state.dispose();
  }

  @override
  B build(BuildContext context) => _state;

  void _listener(dynamic _) {
    setState(() {});
  }

  @override
  Object? get debugValue => _state.value;

  @override
  String get debugLabel => 'useBrick<$T>';
}
