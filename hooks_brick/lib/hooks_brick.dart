import 'package:flutter_brick/flutter_brick.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

abstract class HookBrickConsumerWidget extends BrickConsumerWidget {
  const HookBrickConsumerWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HookBrickConsumerElement createElement() => _HookBrickConsumerElement(this);
}

// ignore: invalid_use_of_visible_for_testing_member
class _HookBrickConsumerElement extends BrickConsumerElement with HookElement {
  _HookBrickConsumerElement(HookBrickConsumerWidget super.widget);
}
