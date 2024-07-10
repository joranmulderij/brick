import 'package:brick/brick.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () async {
    final b1 = MutableBrick((handle) => 12);
    final b2 = Brick((handle) {
      return handle(b1) + 1;
    });
    b1.update(15);
    expect(b2.value, 16);
  });
}
