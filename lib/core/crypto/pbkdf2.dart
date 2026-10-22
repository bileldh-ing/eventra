import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2 with HMAC-SHA256 (RFC 8018), built on the vetted `crypto` package's
/// HMAC. Pure Dart, so it runs the same on every platform and in tests.
Uint8List pbkdf2Sha256({
  required List<int> password,
  required List<int> salt,
  required int iterations,
  int keyLength = 32,
}) {
  if (iterations < 1) throw ArgumentError.value(iterations, 'iterations');
  if (keyLength < 1) throw ArgumentError.value(keyLength, 'keyLength');
  final hmac = Hmac(sha256, password);
  const hLen = 32;
  final blocks = (keyLength + hLen - 1) ~/ hLen;
  final out = Uint8List(blocks * hLen);
  for (var i = 1; i <= blocks; i++) {
    final block = Uint8List(salt.length + 4)
      ..setAll(0, salt)
      ..buffer.asByteData().setUint32(salt.length, i);
    var u = hmac.convert(block).bytes;
    final t = Uint8List.fromList(u);
    for (var c = 1; c < iterations; c++) {
      u = hmac.convert(u).bytes;
      for (var k = 0; k < hLen; k++) {
        t[k] ^= u[k];
      }
    }
    out.setAll((i - 1) * hLen, t);
  }
  return Uint8List.sublistView(out, 0, keyLength);
}

/// Cryptographically secure random bytes.
Uint8List secureRandomBytes(int length, [Random? random]) {
  final r = random ?? Random.secure();
  return Uint8List.fromList(List<int>.generate(length, (_) => r.nextInt(256)));
}

/// URL-safe base64 without padding (tokens, salts, signatures).
String base64UrlNoPad(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

List<int> decodeBase64UrlNoPad(String s) =>
    base64Url.decode(s.padRight((s.length + 3) ~/ 4 * 4, '='));

/// Constant-time comparison so hash checks do not leak timing.
bool constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
