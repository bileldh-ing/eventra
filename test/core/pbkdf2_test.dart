import 'dart:convert';

import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:eventra/features/auth/domain/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  test('PBKDF2-HMAC-SHA256 matches the RFC 7914 test vector', () {
    final out = pbkdf2Sha256(
      password: utf8.encode('passwd'),
      salt: utf8.encode('salt'),
      iterations: 1,
      keyLength: 64,
    );
    expect(
      hex(out),
      '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc'
      '49ca9cccf179b645991664b39d77ef317c71b845b1e30bd509112041d3a19783',
    );
  });

  test('more iterations change the key; bad arguments throw', () {
    List<int> k(int n) => pbkdf2Sha256(
      password: utf8.encode('passwd'),
      salt: utf8.encode('salt'),
      iterations: n,
    );
    expect(hex(k(2)), isNot(hex(k(1))));
    expect(k(1), hasLength(32));
    expect(() => k(0), throwsArgumentError);
  });

  test('constant-time compare and base64url round trip', () {
    expect(constantTimeEquals([1, 2, 3], [1, 2, 3]), isTrue);
    expect(constantTimeEquals([1, 2, 3], [1, 2, 4]), isFalse);
    expect(constantTimeEquals([1, 2], [1, 2, 3]), isFalse);
    final bytes = secureRandomBytes(17);
    final s = base64UrlNoPad(bytes);
    expect(s.contains('='), isFalse);
    expect(decodeBase64UrlNoPad(s), bytes);
  });

  test(
    'PasswordHasher salts each hash and verifies only the right one',
    () async {
      const hasher = PasswordHasher(iterations: 3);
      final a = await hasher.hash('Correct#Horse9');
      final b = await hasher.hash('Correct#Horse9');
      expect(a.salt, isNot(b.salt));
      expect(a.hash, isNot(b.hash));
      expect(a.iterations, 3);
      expect(await hasher.verify('Correct#Horse9', a), isTrue);
      expect(await hasher.verify('correct#horse9', a), isFalse);
    },
  );
}
