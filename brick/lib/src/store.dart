// import 'package:brick/brick.dart';

// abstract class AsyncBrickStore<K, V, Q> {
//   final Map<K, AsyncBrick<V>> _oneCache = {};
//   final Map<Q, AsyncBrick<List<V>>> _allCache = {};

//   AsyncBrick<List<V>> onQuery(Q query);

//   AsyncBrick<V> onOne(K id);

//   AsyncBrick<V> one(K id) {
//     if (_oneCache.containsKey(id)) return _oneCache[id]!;
//     final brick = onOne(id);
//     _oneCache[id] = brick;
//     return brick;
//   }

//   List<AsyncBrick<V>> many(List<K> ids) {
//     return ids.map(one).toList();
//   }

//   AsyncBrick<List<V>> query(Q query, {bool dontCache = false}) {
//     if (!dontCache && _allCache.containsKey(query)) return _allCache[query]!;
//     final brick = onQuery(query);
//     _allCache[query] = brick;
//     return brick;
//   }

//   // B1 createOne(V value);
// }
