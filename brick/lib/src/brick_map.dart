import 'package:brick/src/bricks.dart';

class BrickMap<K, V extends AnyBrick<dynamic, dynamic>> {
  BrickMap(this.createNew);

  final Map<K, V> _map = {};
  final V Function(K) createNew;

  V call(K key) {
    if (!_map.containsKey(key)) {
      _map[key] = createNew(key);
    }
    return _map[key]!;
  }
}
