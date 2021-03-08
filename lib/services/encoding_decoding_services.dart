import 'dart:convert';

import 'encryption_service.dart';


class EncodingDecodingService {
  static String encodeAndEncrypt(
      String data, String ivPassword, String password) {
    String encodedString = jsonEncode(data);

    return EncryptionService.encrypt(ivPassword, password, encodedString);
  }

  static String decryptAndDecode(
      String data, String ivPassword, String password) {
    String decryptedString =
    EncryptionService.decrypt(ivPassword, password, data);

    return jsonDecode(decryptedString);
  }
}