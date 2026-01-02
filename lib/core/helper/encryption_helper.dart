import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:my_secure_note_app/core/helper/key_generator.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();

  EncryptionService._internal();

  factory EncryptionService() {
    return _instance;
  }

  encrypt.Key? _key;
  encrypt.Key? _secureKey;

  void init(String keyString) {
    _key = encrypt.Key.fromUtf8(keyString);
  }

  void initForSecureKey(String password) {
    String compactablePassword = generate128BitString(password);
    _secureKey = encrypt.Key.fromUtf8(compactablePassword);
  }

  encryptSecureKey(String? secureKey) {
    return encryptData(secureKey, isSecureKey: true);
  }

  decryptSecureKey(String? encryptedSecureKey) {
    return decryptData(encryptedSecureKey, isSecureKey: true);
  }

  String encryptData(
    String? plainText, {
    bool isSecureKey = false,
    bool isForPublicKey = false,
  }) {
    if (plainText == "" || plainText == null) {
      return "";
    }
    try {
      if (isSecureKey) {
        if (_secureKey == null) {
          throw Exception('Encryption key is not initialized.');
        }
      } else {
        if (_key == null) {
          throw Exception('Encryption key is not initialized.');
        }
      }
      final iv = encrypt.IV.allZerosOfLength(16);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          isSecureKey == true ? _secureKey! : _key!,
          mode: encrypt.AESMode.cbc,
        ),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final ivBase64 = iv.base64;
      final encryptedBase64 = encrypted.base64;
      return '$ivBase64:$encryptedBase64';
    } catch (e) {
      return "";
    }
  }

  String decryptData(String? encryptedData, {bool isSecureKey = false}) {
    if (encryptedData == "" || encryptedData == null) {
      return "";
    }
    try {
      if (isSecureKey) {
        if (_secureKey == null) {
          throw Exception('Encryption key is not initialized.');
        }
      } else {
        if (_key == null) {
          throw Exception('Encryption key is not initialized.');
        }
      }

      if (!encryptedData.contains(':')) {
        return encryptedData;
      }
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        return encryptedData;
      }
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          isSecureKey == true ? _secureKey! : _key!,
          mode: encrypt.AESMode.cbc,
          padding: "PKCS7",
        ),
      );
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return decrypted;
    } catch (e) {
      return "";
    }
  }
}
