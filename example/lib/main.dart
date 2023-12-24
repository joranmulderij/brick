import 'package:brick/brick.dart';
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

final pbBrick = PocketbaseRecordBrick(
  pocketbaseBrick: brick(() => PocketBase('https://joranmulderij.com/')),
  collectionNameBrick: brick(() => 'test'),
  recordIdBrick: idBrick,
);

class HomeScreen extends BrickConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, listen) {
    final pb = listen(pbBrick);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: switch (pb) {
          AsyncLoading() => const CircularProgressIndicator(),
          AsyncError() => const Text('Error'),
          AsyncData(:final value) =>
            Text('Hello ${value.getStringValue('title')}'),
        },
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
