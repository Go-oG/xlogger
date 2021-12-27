import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:jovial_misc/io_utils.dart';
import 'package:pointycastle/api.dart';

class LoganParser {
  static String ALGORITHM = "AES";
  static String ALGORITHM_TYPE = "AES/CBC/NoPadding";
  late final List<int> mEncryptKey16; //128位ase加密Key
  late final List<int> mEncryptIv16; //128位aes加密IV
  late final BlockCipher cipher;
  final Padding padding = Padding('NoPadding');

  LoganParser(String encryptKey16, String encryptIv16) {
    mEncryptKey16 = utf8.encode(encryptKey16);
    mEncryptIv16 = utf8.encode(encryptIv16);
    final key = Uint8List.fromList(mEncryptKey16);
    CipherParameters cipherParameters = ParametersWithIV(KeyParameter(key), Uint8List.fromList(mEncryptIv16));
    cipher = BlockCipher(ALGORITHM_TYPE);
    cipher.init(false, cipherParameters);
  }

  Future<String> parse(File inputFile) async {
    BytesBuilder resultBuffer = BytesBuilder();
    Uint8List content = inputFile.readAsBytesSync();
    for (int i = 0; i < content.length; i++) {
      int start = content[i];
      if (start != '\u000E'.codeUnitAt(0)) {
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
        } else if (content.length - i - 1 > length && '\0'.codeUnitAt(0) == content[temp]) {
          type = 1;
        } else if (content.length - i - 1 > length && '\u000E'.codeUnitAt(0) == content[temp]) {
          //异常
          type = 2;
        } else {
          i -= 4;
          continue;
        }

        ByteData dest = ByteData(length);
        for (int j = 0; j < length; j++) {
          dest.setUint8(j, content.getRange((i + 1 + j), (i + 1 + j + 1)).first);
        }

        BytesBuilder uncompressBytesArray = BytesBuilder();
        uncompressBytesArray.clear();
        DataInputStream dataInputStream = DataInputStream(Stream.value(dest.buffer.asUint8List()));
        DecryptingStream inflaterOs = DecryptingStream.fromDataInputStream(cipher, dataInputStream, padding);

        List<Uint8List> list = await inflaterOs.toList();
        List<int> convertList = [];
        for (var element in list) {
          convertList.addAll(element.buffer.asUint8List());
        }

        //ZIP 解密
        Archive archive = ZipDecoder().decodeBytes(convertList);
        for (var file in archive.files) {
          if (file.isFile) {
            List<int> content = file.content;
            uncompressBytesArray.add(content);
          }
        }
        resultBuffer.add(uncompressBytesArray.toBytes().toList());
        uncompressBytesArray.clear();
        i += length;
        if (type == 1) {
          i++;
        }
      }
    }
    String result = String.fromCharCodes(resultBuffer.toBytes());
    return Future.value(result);
  }

}
