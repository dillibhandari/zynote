import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';

Future<String> generateRandomKey(String password) async {
  // encrypt.Key? key = encrypt.Key.fromSecureRandom(32);
  encrypt.Key? key = encrypt.Key.fromUtf8(password);
  String scaleString128 = generate128BitString(key.base64);
  await saveGlobalKey(scaleString128);
  return scaleString128;
}

saveGlobalKey(String globalKey) async {
  AppSettings().globalKey = globalKey;
}

String generate128BitString(String input) {
  // Generate SHA-256 hash
  var bytes = utf8.encode(input);
  var digest = sha256.convert(bytes);
  // Truncate to 128 bits (16 bytes)
  Uint8List truncated = Uint8List.fromList(digest.bytes.sublist(0, 16));
  // Convert to a string or hexadecimal
  return base64Url.encode(truncated);
}
