import 'package:brick/brick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_brick/use_brick.dart';
import 'package:hooks_brick/use_create_brick.dart';

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

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final f = useCreateMutableBrick((handle) => false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        children: [
          TestWidget(f),
          Text(f.value.toString()),
          TestWidget(f),
        ],
      ),
    );
  }
}

class TestWidget extends HookWidget {
  const TestWidget(this.brick, {super.key});

  final MutableBrick<bool> brick;

  @override
  Widget build(BuildContext context) {
    final checked = useBrick(brick);
    return CheckboxListTile(
      value: checked,
      onChanged: (value) => brick.update(value ?? false),
    );
  }
}
