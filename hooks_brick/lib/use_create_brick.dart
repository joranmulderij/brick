import 'package:brick/brick.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Brick<T> useCreateBrick<T>(
  T Function(BrickHandle handle) onRead, [
  bool listenToBrick = false,
]) {
  return use(_CreateBrickHook(
    onRead: onRead,
    brickBuilder: Brick.new,
    listenToBrick: listenToBrick,
  ));
}

MutableBrick<T> useCreateMutableBrick<T>(
  T Function(BrickHandle handle) onRead, [
  bool listenToBrick = false,
]) {
  return use(_CreateBrickHook(
    onRead: onRead,
    brickBuilder: MutableBrick.new,
    listenToBrick: listenToBrick,
  ));
}

class _CreateBrickHook<T, B extends Brick<T>> extends Hook<B> {
  const _CreateBrickHook({
    required this.onRead,
    required this.brickBuilder,
    required this.listenToBrick,
  });

  final T Function(BrickHandle handle) onRead;
  final B Function(T Function(BrickHandle)) brickBuilder;
  final bool listenToBrick;

  @override
  _CreateBrickHookState<T, B> createState() => _CreateBrickHookState<T, B>();
}

class _CreateBrickHookState<T, B extends Brick<T>>
    extends HookState<B, _CreateBrickHook<T, B>> {
  late final B _state;

  @override
  void initHook() {
    _state = hook.brickBuilder(hook.onRead);
    if (hook.listenToBrick) {
      _state.addListener(_listener);
    }
    super.initHook();
  }

  @override
  void dispose() {
    _state.dispose();
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
