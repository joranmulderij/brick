import 'package:brick/brick.dart';
import 'package:brick_widgets/brick_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_brick/hooks_brick.dart';
import 'package:hooks_brick/use_brick.dart';
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

final idBrick = mutableBrick((handle) => 'uol4xf9umd8n3fk');

final titleBrick = mutableBrick((handle) => 'Hello World');

final pbBrick = PocketbaseBrick(
  pocketbaseBrick: brick((handle) => PocketBase('https://joranmulderij.com/')),
  collectionNameBrick: brick((handle) => 'test'),
  recordIdBrick: idBrick,
  fromJson: (json) => json,
  toJson: (data) => data,
);

final pbStoreBrick = PocketbaseBrickStore(
  pocketbaseBrick: brick((handle) => PocketBase('https://joranmulderij.com/')),
  collectionNameBrick: brick((handle) => 'test'),
  toJson: (data) => data,
  fromJson: (json) => json,
);

final counterBrick = mutableBrick((handle) => 0);

class HomeScreen extends HookBrickConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, BrickHandle handle) {
    final pb = handle.listen(pbBrick);
    final pbStore = handle.listen(pbStoreBrick.query(PocketbaseQuery()));
    final title = handle.listen(titleBrick);
    final checkedBrick = useMutableBrick((handle) => false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Row(
        children: [
          Expanded(
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
                TextButton(
                  onPressed: () {
                    counterBrick.update(counterBrick.value + 1);
                  },
                  child: const Text('increment'),
                ),
                Text(handle.listen(counterBrick).toString()),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return const TestWidget();
              },
              itemCount: 100,
            ),
          ),
        ],
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

class TestWidget extends HookBrickConsumerWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context, BrickHandle handle) {
    final checkedBrick = useMutableBrick((handle) {
      handle.listen(counterBrick);
      return false;
    });
    return CheckboxListTile(
      value: checkedBrick.value,
      onChanged: (value) => checkedBrick.update(value ?? false),
    );
  }
}
