import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart';

class LoganParser {
  static String ALGORITHM = "AES";
  static String ALGORITHM_TYPE = "AES/CBC/NoPadding";
  late final List<int> mEncryptKey16; //128位ase加密Key
  late final List<int> mEncryptIv16; //128位aes加密IV
  //====
  late final IV iv;
  late final Key key;
  late Encrypter encrypter;

  LoganParser(String encryptKey16, String encryptIv16) {
    mEncryptKey16 = utf8.encode(encryptKey16);
    mEncryptIv16 = utf8.encode(encryptIv16);
    //===
    iv = IV.fromUtf8(encryptIv16);
    key = Key.fromUtf8(encryptIv16);
    encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: null));
  }

  Future<String> parse(File inputFile) async {
    BytesBuilder resultBuffer = BytesBuilder();
    Uint8List content = inputFile.readAsBytesSync();

    var gzipDecoder = GZipDecoder();
    for (int i = 0; i < content.length; i++) {
      int start = content[i];
      if (start != '\u0001'.codeUnitAt(0)) {
        continue;
      }

      i++;
      int length = (content[i] & 0xFF) << 24 | (content[i + 1] & 0xFF) << 16 | (content[i + 2] & 0xFF) << 8 | (content[i + 3] & 0xFF);
      i += 3;
      int type;
      if (length > 0) {
        int temp = i + length + 1;
        if (content.length - i - 1 == length) {
          //异常
          type = 0;
        } else if (content.length - i - 1 > length && '\u0000'.codeUnitAt(0) == content[temp]) {
          type = 1;
        } else if (content.length - i - 1 > length && '\u0001'.codeUnitAt(0) == content[temp]) {
          //异常
          type = 2;
        } else {
          i -= 4;
          continue;
        }

        Uint8List dest = Uint8List.fromList(content.getRange(i + 1, i + 1 + length).toList());
        BytesBuilder uncompressBytesArray = BytesBuilder();
        uncompressBytesArray.clear();

        var encrypted = Encrypted(dest.buffer.asUint8List());
        List<int> tempconvertList = encrypter.decryptBytes(encrypted, iv: iv);

        Uint8List convertList = Uint8List.fromList(tempconvertList);
        //GZIP 解压
        try {
          List<int> data = gzipDecoder.decodeBytes(convertList);
          uncompressBytesArray.add(data);
        } catch (error) {
          print(error);
        }
        resultBuffer.add(uncompressBytesArray.toBytes().toList());
        uncompressBytesArray.clear();
        i += length;
        if (type == 1) {
          i++;
        }
      }
    }
    return String.fromCharCodes(resultBuffer.toBytes());
  }
}
