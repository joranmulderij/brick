import 'package:brick/brick.dart';
import 'package:hive/hive.dart' as hive;

class HiveBrick<T, S> extends MutableBrick<T> {
  HiveBrick({
    required this.hiveBox,
    required this.hiveKey,
    required this.serialize,
    required this.deserialize,
    required this.defaultValue,
  });

  final hive.Box<S> hiveBox;
  final String hiveKey;
  final S Function(T) serialize;
  final T Function(S) deserialize;
  final T Function() defaultValue;

  @override
  T onRead() {
    final value = hiveBox.get(hiveKey);
    if (value is! S) {
      return defaultValue();
    } else {
      return deserialize(value);
    }
  }

  @override
  T onUpdate(newValue) {
    hiveBox.put(hiveKey, serialize(newValue));
    return newValue;
  }
}
