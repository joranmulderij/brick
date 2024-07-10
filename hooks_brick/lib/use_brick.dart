import 'package:brick/brick.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

T useBrick<T>(Brick<T> brick) {
  return use(_BrickHook<T>(brick)).value;
}

class _BrickHook<T> extends Hook<Brick<T>> {
  const _BrickHook(this.brick);

  final Brick<T> brick;

  @override
  _BrickHookState<T> createState() => _BrickHookState<T>();
}

class _BrickHookState<T> extends HookState<Brick<T>, _BrickHook<T>> {
  late final Brick<T> _state;

  @override
  void initHook() {
    _state = hook.brick..addListener(_listener);
    super.initHook();
  }

  @override
  Brick<T> build(BuildContext context) => _state;

  void _listener<T2>(T2 _) {
    setState(() {});
  }

  @override
  Object? get debugValue => _state.value;

  @override
  String get debugLabel => 'useBrick<$T>';
}
