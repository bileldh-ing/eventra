import 'dart:convert';
import 'dart:isolate';

import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:meta/meta.dart';

/// Stored password verifier: PBKDF2-HMAC-SHA256 hash, per-user salt and the
/// iteration count used (so it can be raised later without breaking logins).
@immutable
class PasswordHash {
  const PasswordHash({
    required this.hash,
    required this.salt,
    required this.iterations,
  });
  final String hash;
  final String salt;
  final int iterations;
}

/// Salted PBKDF2 password hashing. Heavy work runs on a background isolate
/// so the UI never janks; tests use a low iteration count.
class PasswordHasher {
  const PasswordHasher({this.iterations = defaultIterations});

  static const defaultIterations = 60000;

  /// Above this, hashing moves off the UI isolate.
  static const _isolateThreshold = 20000;

  final int iterations;

  Future<PasswordHash> hash(String password, {List<int>? salt}) async {
    final s = salt ?? secureRandomBytes(16);
    final derived = await _derive(password, s, iterations);
    return PasswordHash(
      hash: base64UrlNoPad(derived),
      salt: base64UrlNoPad(s),
      iterations: iterations,
    );
  }

  Future<bool> verify(String password, PasswordHash stored) async {
    final derived = await _derive(
      password,
      decodeBase64UrlNoPad(stored.salt),
      stored.iterations,
    );
    return constantTimeEquals(derived, decodeBase64UrlNoPad(stored.hash));
  }

  static Future<List<int>> _derive(String pw, List<int> salt, int n) {
    List<int> run() =>
        pbkdf2Sha256(password: utf8.encode(pw), salt: salt, iterations: n);
    return n >= _isolateThreshold ? Isolate.run(run) : Future.value(run());
  }
}
