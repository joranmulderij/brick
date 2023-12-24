import 'package:brick/brick.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketbaseRecordBrick extends AsyncMutableBrick<RecordModel> {
  PocketbaseRecordBrick({
    required this.pocketbaseBrick,
    required this.collectionNameBrick,
    required this.recordIdBrick,
  });

  final Brick<PocketBase> pocketbaseBrick;
  final Brick<String> collectionNameBrick;
  final Brick<String> recordIdBrick;

  @override
  Future<RecordModel> onUpdate(RecordModel newValue) async {
    final pocketbase = listen(pocketbaseBrick);
    final collectionName = listen(collectionNameBrick);
    final recordId = listen(recordIdBrick);
    return await pocketbase
        .collection(collectionName)
        .update(recordId, body: newValue.data);
  }

  @override
  Future<RecordModel> onRead() {
    final pocketbase = listen(pocketbaseBrick);
    final collectionName = listen(collectionNameBrick);
    final recordId = listen(recordIdBrick);
    return pocketbase.collection(collectionName).getOne(recordId);
  }
}
