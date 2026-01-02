import 'dart:convert';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';

class RSAService {
  String get publicKey => _publicKey ?? "";
  String get privateKey => _privateKey ?? "";
  String? _publicKey;
  set publicKey(String value) {
    _publicKey = value;
  }

  String? _privateKey;
  set privateKey(String value) {
    _privateKey = value;
  }

  Future<Keys> generatePublicPrivateKeys() async {
    final rsa = await RSA.generate(2048);
    final publicKey = rsa.publicKey;
    final privateKey = rsa.privateKey;
    this.publicKey = publicKey;
    this.privateKey = privateKey;
    await saveKeys(Keys(privateKey, publicKey));
    return Keys(privateKey, publicKey);
  }

  // Encrypt plaintext with the public key
  Future<String> encryptData(String? plaintext, {String? userPublicKey}) async {
    try {
      if (plaintext != "" && plaintext != null) {
        String publicKey = userPublicKey ?? getPublicKey();
        final bytes = utf8.encode(plaintext); // Convert string to bytes
        final base64Str = base64.encode(bytes); // Encode bytes to Base64
        final encryptedData = await RSA.encryptPKCS1v15(base64Str, publicKey);
        return encryptedData;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // Decrypt ciphertext with the private key
  Future<String> decryptData(String? encryptedText) async {
    try {
      if (encryptedText != "" || encryptedText != null) {
        String privateKey = getPrivateKey();
        final decryptedData = await RSA.decryptPKCS1v15(
          encryptedText!,
          privateKey,
        );
        List<int> decodedBytes = base64Decode(decryptedData);
        String normalString = utf8.decode(decodedBytes);
        return normalString;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  String getPrivateKey() {
    if (privateKey != "") {
      return privateKey;
    } else {
      String privateKey = AppSettings().privateKey;
      this.privateKey = privateKey;
      return privateKey;
    }
  }

  String getPublicKey() {
    if (publicKey != "") {
      return publicKey;
    } else {
      String publicKey = AppSettings().publicKey;
      this.publicKey = publicKey;
      return publicKey;
    }
  }

  saveKeys(Keys keys) async {
    AppSettings().privateKey = keys.privateKey;
    AppSettings().publicKey = keys.publicKey;
  }
}

class Keys {
  final String privateKey;
  final String publicKey;
  const Keys(this.privateKey, this.publicKey);
}
