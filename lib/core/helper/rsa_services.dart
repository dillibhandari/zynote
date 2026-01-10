import 'dart:convert';
import 'dart:math';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:my_secure_note_app/core/helper/encryption_helper.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';

class RSAService {
  final EncryptionService _encryptionService = EncryptionService();
  String? _cachedGlobalKey;

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
    if (plaintext == null || plaintext.isEmpty) {
      return "";
    }
    try {
      if (userPublicKey == null || userPublicKey.isEmpty) {
        final encrypted = _encryptWithSymmetricKey(plaintext);
        if (encrypted.isNotEmpty) {
          return encrypted;
        }
      }
      final publicKey = userPublicKey ?? getPublicKey();
      if (publicKey.isEmpty) {
        return "";
      }
      final bytes = utf8.encode(plaintext);
      final base64Str = base64.encode(bytes);
      return await RSA.encryptPKCS1v15(base64Str, publicKey);
    } catch (e) {
      return "";
    }
  }

  // Decrypt ciphertext with the private key
  Future<String> decryptData(String? encryptedText) async {
    if (encryptedText == null || encryptedText.isEmpty) {
      return "";
    }
    try {
      if (encryptedText.contains(':')) {
        final decrypted = _decryptWithSymmetricKey(encryptedText);
        if (decrypted.isNotEmpty) {
          return decrypted;
        }
      }
      final privateKey = getPrivateKey();
      if (privateKey.isEmpty) {
        return "";
      }
      final decryptedData = await RSA.decryptPKCS1v15(
        encryptedText,
        privateKey,
      );
      final decodedBytes = base64Decode(decryptedData);
      return utf8.decode(decodedBytes);
    } catch (e) {
      return "";
    }
  }

  String getPrivateKey() {
    if (privateKey.isNotEmpty) {
      return privateKey;
    } else {
      final storedPrivateKey = AppSettings().privateKey;
      this.privateKey = storedPrivateKey;
      return storedPrivateKey;
    }
  }

  String getPublicKey() {
    if (publicKey.isNotEmpty) {
      return publicKey;
    } else {
      final storedPublicKey = AppSettings().publicKey;
      this.publicKey = storedPublicKey;
      return storedPublicKey;
    }
  }

  saveKeys(Keys keys) async {
    AppSettings().privateKey = keys.privateKey;
    AppSettings().publicKey = keys.publicKey;
  }

  String _encryptWithSymmetricKey(String plainText) {
    _ensureSymmetricKeyInitialized();
    if (_cachedGlobalKey == null || _cachedGlobalKey!.isEmpty) {
      return "";
    }
    return _encryptionService.encryptData(plainText);
  }

  String _decryptWithSymmetricKey(String encryptedText) {
    _ensureSymmetricKeyInitialized();
    if (_cachedGlobalKey == null || _cachedGlobalKey!.isEmpty) {
      return "";
    }
    return _encryptionService.decryptData(encryptedText);
  }

  void _ensureSymmetricKeyInitialized() {
    final globalKey = _getOrCreateGlobalKey();
    if (globalKey.isEmpty) {
      return;
    }
    if (_cachedGlobalKey != globalKey) {
      _cachedGlobalKey = globalKey;
      _encryptionService.init(globalKey);
    }
  }

  String _getOrCreateGlobalKey() {
    if (_cachedGlobalKey != null && _cachedGlobalKey!.isNotEmpty) {
      return _cachedGlobalKey!;
    }
    final storedKey = AppSettings().globalKey;
    if (storedKey.isNotEmpty) {
      final normalized = _normalizeKeyTo32(storedKey);
      if (normalized != storedKey) {
        AppSettings().globalKey = normalized;
      }
      _cachedGlobalKey = normalized;
      return normalized;
    }
    final generatedKey = _generateAsciiKey(32);
    AppSettings().globalKey = generatedKey;
    _cachedGlobalKey = generatedKey;
    return generatedKey;
  }

  String _generateAsciiKey(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _normalizeKeyTo32(String key) {
    if (key.length == 32) {
      return key;
    }
    final bytes = utf8.encode(key);
    final base64Key = base64Url.encode(bytes);
    if (base64Key.length >= 32) {
      return base64Key.substring(0, 32);
    }
    return base64Key.padRight(32, '0');
  }
}

class Keys {
  final String privateKey;
  final String publicKey;
  const Keys(this.privateKey, this.publicKey);
}
