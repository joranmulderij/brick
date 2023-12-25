import 'package:brick/brick.dart';
import 'package:brick_widgets/brick_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brick/flutter_brick.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_brick/pocketbase_brick.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

final idBrick = mutableBrick(() => 'uol4xf9umd8n3fk');

final titleBrick = mutableBrick(() => 'Hello World');

final pbBrick = PocketbaseBrick(
  pocketbaseBrick: brick(() => PocketBase('https://joranmulderij.com/')),
  collectionNameBrick: brick(() => 'test'),
  recordIdBrick: idBrick,
  fromJson: (json) => json,
  toJson: (data) => data,
);

final pbStoreBrick = PocketbaseBrickStore(
  pocketbaseBrick: brick(() => PocketBase('https://joranmulderij.com/')),
  collectionNameBrick: brick(() => 'test'),
  toJson: (data) => data,
  fromJson: (json) => json,
);

class HomeScreen extends BrickConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle handle) {
    final pb = handle.listen(pbBrick);
    final pbStore = handle.listen(pbStoreBrick.getAll(''));
    final title = handle.listen(titleBrick);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (pb) {
              AsyncLoading() => const CircularProgressIndicator(),
              AsyncError() => const Text('Error'),
              AsyncData(:final value) => Text('Hello ${value['title']}'),
            },
            switch (pbStore) {
              AsyncLoading() => const CircularProgressIndicator(),
              AsyncError() => const Text('Error'),
              AsyncData(:final value) => Text('Hello ${value.length}'),
            },
            const SizedBox(height: 16),
            Text(title),
            const SizedBox(height: 16),
            BrickTextField(titleBrick),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          idBrick.update('z212kl8m9l6rxlb');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
