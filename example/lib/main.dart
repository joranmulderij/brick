import 'package:brick/brick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brick/flutter_brick.dart';

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

final myBrick = MutableBrick.functional(() => 0);

class HomeScreen extends BrickConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, listen) {
    final count = listen(myBrick);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Text('Count: $count'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          myBrick.update(count + 1);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
