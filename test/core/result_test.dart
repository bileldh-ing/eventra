import 'package:eventra/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('success folds, maps and exposes its value', () {
    const r = Result<int>.success(2);
    expect(r.isSuccess, isTrue);
    expect(r.valueOrNull, 2);
    expect(r.map((v) => v * 10).valueOrNull, 20);
    expect(r.fold((v) => 'ok $v', (f) => 'fail'), 'ok 2');
  });

  test('failure keeps the failure through map', () {
    const r = Result<int>.failure(NetworkFailure());
    expect(r.isSuccess, isFalse);
    expect(r.valueOrNull, isNull);
    final mapped = r.map((v) => v * 10);
    expect(mapped, isA<Failure<int>>());
    expect((mapped as Failure<int>).failure, isA<NetworkFailure>());
    expect(r.fold((v) => 'ok', (f) => f.message), contains('connection'));
  });

  test('FailureException carries a readable message', () {
    expect(
      const FailureException(NotFoundFailure()).toString(),
      contains('no longer available'),
    );
  });
}
