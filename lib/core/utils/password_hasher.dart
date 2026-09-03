import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

abstract final class PasswordHasher {
  static final _random = Random.secure();
  static String hash(String value, {String? salt}) {
    final actualSalt =
        salt ??
        base64UrlEncode(List<int>.generate(16, (_) => _random.nextInt(256)));
    List<int> digest = utf8.encode('$actualSalt:$value');
    for (var i = 0; i < 120000; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return '$actualSalt\$${base64UrlEncode(digest)}';
  }

  static bool verify(String value, String encodedHash) {
    final parts = encodedHash.split('\$');
    return parts.length == 2 && hash(value, salt: parts.first) == encodedHash;
  }
}
