import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stack_trace/stack_trace.dart';

class XLogger {
  static const _lineMax = 4 * 1024 - 500;

  static const _topLeftCorner = '┌';
  static const _bottomLeftCorner = '└';
  static const _middleCorner = '├';
  static const _verticalLine = '│';
  static const _doubleDivider = '─';
  static const _singleDivider = '┄';

  static bool _enable = true;
  static const _encoder = JsonEncoder.withIndent(null);

  static _LogColor _colorV = _LogColor.rgb(187, 187, 187);
  static _LogColor _colorD = _LogColor.rgb(37, 188, 36);
  static _LogColor _colorI = _LogColor.rgb(255, 255, 0);
  static _LogColor _colorW = _LogColor.rgb(255, 85, 85);
  static _LogColor _colorE = _LogColor.rgb(187, 0, 0);

  static void setEnable(bool enable) {
    _enable = enable;
  }

  static void setLogColor(Level level, Color color) {
    if (level == Level.V) {
      _colorV = _LogColor.color(color);
      return;
    }
    if (level == Level.D) {
      _colorD = _LogColor.color(color);
      return;
    }
    if (level == Level.I) {
      _colorI = _LogColor.color(color);
      return;
    }
    if (level == Level.W) {
      _colorW = _LogColor.color(color);
      return;
    }
    if (level == Level.E) {
      _colorE = _LogColor.color(color);
      return;
    }
  }

  static void v(String tag, dynamic content, {bool saveToFile = false}) {
    _printLog(Level.V, tag, content, saveToFile);
  }

  static void d(String tag, dynamic content, {bool saveToFile = false}) {
    _printLog(Level.D, tag, content, saveToFile);
  }

  static void i(String tag, dynamic content, {bool saveToFile = false}) {
    _printLog(Level.I, tag, content, saveToFile);
  }

  static void w(String tag, dynamic content, {bool saveToFile = false}) {
    _printLog(Level.W, tag, content, saveToFile);
  }

  static void e(String tag, dynamic content, {bool saveToFile = false}) {
    _printLog(Level.E, tag, content, saveToFile);
  }

  static void _printLog(Level level, String tag, dynamic content, bool saveToFile) {
    if (_enable) {
      String color = _colorD.getHead();
      if (level == Level.V) {
        color = _colorV.getHead();
      } else if (level == Level.I) {
        color = _colorI.getHead();
      } else if (level == Level.W) {
        color = _colorW.getHead();
      } else if (level == Level.E) {
        color = _colorE.getHead();
      }
      _printDetail(_convertLog(_stringifyMessage(content)), color);
    }

    if (saveToFile) {
      _FlutterLogan.log(1, content);
    }
  }

  //转为字符串
  static String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      return _encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }

  ///转换并处理超长字符串，比如在Android 上 超过4096个字符的数据会被截断
  static List<String> _convertLog(String log) {
    List<String> list = List.empty(growable: true);
    int lineMaxCount = 0; //记录日志中最长行的宽度 //必须小于4096
    List<String> tempList = log.split(RegExp.escape('\n'));
    for (var s in tempList) {
      int sl = s.length;
      if (sl <= _lineMax) {
        list.add(s);
        if (sl > lineMaxCount) {
          lineMaxCount = sl;
        }
        continue;
      }
      Characters characters = s.characters;
      while (characters.length > _lineMax) {
        list.add(characters.getRange(0, _lineMax).toString());
        characters = characters.getRange(_lineMax, characters.length);
        if (lineMaxCount < _lineMax) {
          lineMaxCount = _lineMax;
        }
      }
      String sc = characters.toString();
      if (sc.isNotEmpty) {
        list.add(sc);
        if (sc.length > lineMaxCount) {
          lineMaxCount = sc.length;
        }
      }
    }

    //调用栈处理
    String staceInfo = "暂无调用帧";
    var chain = Chain.current();
    chain = chain.foldFrames((frame) => frame.isCore || frame.package == "flutter");
    final frames = chain.toTrace().frames;
    final idx = frames.indexWhere((element) => !element.library.contains("logger2/logger.dart"));
    if (idx == -1 || idx + 1 >= frames.length) {
    } else {
      final frame = frames[idx];
      staceInfo = "${frame.library}(${frame.line})";
    }
    if(staceInfo.length>lineMaxCount){
      lineMaxCount=staceInfo.length;
    }

    //数据拼接
    List<String> resultList = List.empty(growable: true);
    StringBuffer buffer = StringBuffer(_topLeftCorner);
    for (int i = 0; i < lineMaxCount + 2; i++) {
      buffer.write(_doubleDivider);
    }
    resultList.add(buffer.toString());
    buffer.clear();
    buffer.write(_verticalLine);
    buffer.write(" $staceInfo");

    resultList.add(buffer.toString());
    buffer.clear();

    buffer.write(_middleCorner);
    for (int i = 0; i < lineMaxCount + 2; i++) {
      buffer.write(_singleDivider);
    }
    resultList.add(buffer.toString());
    buffer.clear();

    for (var s in list) {
      resultList.add("$_verticalLine $s");
    }
    buffer.write(_bottomLeftCorner);
    for (int i = 0; i < lineMaxCount + 2; i++) {
      buffer.write(_doubleDivider);
    }
    resultList.add(buffer.toString());
    return resultList;
  }

  static void _printDetail(List<String> list, String color) {
    int i = 0;
    for (var s in list) {
      if (i == 0) {
        print('$color$s');
      } else if (i == list.length - 1) {
        print("$s${_LogColor.ansiDefault}");
      } else {
        print(s);
      }
      i++;
    }
  }
}

class _LogColor {
  static const ansiEsc = '\x1B[38;2;';
  static const ansiDefault = '\x1B[0m';
  late final int r;
  late final int g;
  late final int b;

  _LogColor.rgb(this.r, this.g, this.b);

  _LogColor.color(Color color) {
    r = color.red;
    g = color.green;
    b = color.blue;
  }

  String getHead() {
    return "$ansiEsc$r;$g;${b}m";
  }
}

enum Level { V, D, I, W, E }

class _FlutterLogan {
  static const MethodChannel _channel = MethodChannel('flutter_logan');

  static Future<bool> init(String aseKey, String aesIv, int maxFileLen) async {
    final bool result = await _channel.invokeMethod('init', {'aesKey': aseKey, 'aesIv': aesIv, 'maxFileLen': maxFileLen});
    return result;
  }

  static Future<void> log(int type, String log) async {
    await _channel.invokeMethod('log', {'type': type, 'log': log});
  }

  static Future<String> getUploadPath(String date) async {
    final String result = await _channel.invokeMethod('getUploadPath', {'date': date});
    return result;
  }

  static Future<bool> upload(String serverUrl, String date, String appId, String unionId, String deviceId) async {
    final bool result = await _channel
        .invokeMethod('upload', {'date': date, 'serverUrl': serverUrl, 'appId': appId, 'unionId': unionId, 'deviceId': deviceId});
    return result;
  }

  static Future<void> flush() async {
    await _channel.invokeMethod('flush');
  }

  static Future<void> cleanAllLogs() async {
    await _channel.invokeMethod('cleanAllLogs');
  }
}
