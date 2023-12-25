import 'package:brick/brick.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketbaseBrick<T> extends AsyncMutableBrick<T> {
  PocketbaseBrick({
    required this.pocketbaseBrick,
    required this.collectionNameBrick,
    required this.recordIdBrick,
    required this.fromJson,
    required this.toJson,
  });

  final Brick<PocketBase> pocketbaseBrick;
  final Brick<String> collectionNameBrick;
  final Brick<String> recordIdBrick;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  @override
  Future<T> onUpdate(T newValue) async {
    final pocketbase = listen(pocketbaseBrick);
    final collectionName = listen(collectionNameBrick);
    final recordId = listen(recordIdBrick);
    final res = await pocketbase
        .collection(collectionName)
        .update(recordId, body: toJson(newValue));
    return fromJson(res.toJson());
  }

  @override
  Future<T> onRead() async {
    final pocketbase = listen(pocketbaseBrick);
    final collectionName = listen(collectionNameBrick);
    final recordId = listen(recordIdBrick);
    final res = await pocketbase.collection(collectionName).getOne(recordId);
    return fromJson(res.toJson());
  }
}

class PocketbaseFullListBrick<T> extends AsyncBrick<List<T>> {
  PocketbaseFullListBrick({
    required this.pocketbaseBrick,
    required this.collectionNameBrick,
    required this.filterBrick,
    required this.fromJson,
  });

  final Brick<PocketBase> pocketbaseBrick;
  final Brick<String> collectionNameBrick;
  final Brick<String?>? filterBrick;
  final T Function(Map<String, dynamic>) fromJson;

  @override
  Future<List<T>> onRead() async {
    final pocketbase = listen(pocketbaseBrick);
    final collectionName = listen(collectionNameBrick);
    final filter = listenNullable(filterBrick);
    final res = await pocketbase.collection(collectionName).getFullList(
          filter: filter,
        );
    return res.map((e) => fromJson(e.toJson())).toList();
  }
}

class PocketbaseBrickStore<T> extends AsyncBrickStore<String, T, String,
    PocketbaseBrick<T>, PocketbaseFullListBrick<T>> {
  PocketbaseBrickStore({
    required this.pocketbaseBrick,
    required this.collectionNameBrick,
    required this.fromJson,
    required this.toJson,
  });

  final Brick<PocketBase> pocketbaseBrick;
  final Brick<String> collectionNameBrick;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  RecordService get collection {
    return pocketbaseBrick.value.collection(
      collectionNameBrick.value,
    );
  }

  @override
  PocketbaseBrick<T> onGetOne(String id) {
    return PocketbaseBrick(
      pocketbaseBrick: pocketbaseBrick,
      collectionNameBrick: collectionNameBrick,
      recordIdBrick: mutableBrick(() => id),
      fromJson: fromJson,
      toJson: toJson,
    );
  }

  @override
  PocketbaseFullListBrick<T> onGetAll(query) {
    return PocketbaseFullListBrick(
      pocketbaseBrick: pocketbaseBrick,
      collectionNameBrick: collectionNameBrick,
      filterBrick: constBrick(query),
      fromJson: fromJson,
    );
  }
}
