import 'package:brick/brick.dart';

abstract class AsyncBrickStore<K, V, Q, B1 extends AsyncBrick<V>,
    B2 extends AsyncBrick<List<V>>> {
  final Map<K, B1> _oneCache = {};
  final Map<Q, B2> _allCache = {};

  B2 onGetAll(Q query);

  B1 onGetOne(K id);

  B1 getOne(K id) {
    if (_oneCache.containsKey(id)) return _oneCache[id]!;
    final brick = onGetOne(id);
    _oneCache[id] = brick;
    return brick;
  }

  B2 getAll(Q query) {
    if (_allCache.containsKey(query)) return _allCache[query]!;
    final brick = onGetAll(query);
    _allCache[query] = brick;
    return brick;
  }

  // B1 createOne(V value);
}
