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

class PocketbaseListBrick<T> extends AsyncBrick<List<T>> {
  PocketbaseListBrick({
    required this.pocketbaseBrick,
    required this.collectionNameBrick,
    required this.queryBrick,
    required this.fromJson,
  });

  final Brick<PocketBase> pocketbaseBrick;
  final Brick<String> collectionNameBrick;
  final Brick<PocketbaseQuery> queryBrick;
  final T Function(Map<String, dynamic>) fromJson;

  @override
  Future<List<T>> onRead() async {
    final pocketbase = listen(pocketbaseBrick);
    final collectionName = listen(collectionNameBrick);
    final query = listen(queryBrick);
    final res = switch (query.perPage) {
      null => await pocketbase.collection(collectionName).getFullList(
            filter: query.filter,
            sort: query.sort,
          ),
      _ => (await pocketbase.collection(collectionName).getList(
                filter: query.filter,
                sort: query.sort,
                perPage: query.perPage!,
                page: query.page,
              ))
          .items,
    };
    return res.map((e) => fromJson(e.toJson())).toList();
  }
}

class PocketbaseQuery {
  PocketbaseQuery({
    this.filter,
    this.sort,
    this.perPage = 30,
    this.page = 1,
  });

  PocketbaseQuery.all({
    this.filter,
    this.sort,
    this.page = 1,
  }) : perPage = null;

  final String? filter;
  final String? sort;
  final int? perPage;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PocketbaseQuery &&
        other.filter == filter &&
        other.sort == sort &&
        other.perPage == perPage &&
        other.page == page;
  }

  @override
  int get hashCode {
    return filter.hashCode ^ sort.hashCode ^ perPage.hashCode ^ page.hashCode;
  }
}

class PocketbaseBrickStore<T>
    extends AsyncBrickStore<String, T, PocketbaseQuery> {
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
  PocketbaseBrick<T> onOne(String id) {
    return PocketbaseBrick(
      pocketbaseBrick: pocketbaseBrick,
      collectionNameBrick: collectionNameBrick,
      recordIdBrick: mutableBrick((handle) => id),
      fromJson: fromJson,
      toJson: toJson,
    );
  }

  @override
  PocketbaseListBrick<T> onQuery(query) {
    return PocketbaseListBrick(
      pocketbaseBrick: pocketbaseBrick,
      collectionNameBrick: collectionNameBrick,
      queryBrick: constBrick(query),
      fromJson: fromJson,
    );
  }
}
