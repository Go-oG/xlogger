import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:xlogger/log_config.dart';
import 'package:xlogger/xlogger_color.dart';

export 'package:xlogger/xlogger.dart' show XLogger, PrintFilter, Level;
export 'package:xlogger/log_config.dart' show XLoggerConfig;

class XLogger {
  static const _topLeftCorner = '┌';
  static const _bottomLeftCorner = '└';
  static const _middleCorner = '├';
  static const _verticalLine = '│';
  static const _doubleDivider = '─';
  static const _encoder = JsonEncoder.withIndent('\t');

  ///匹配英文字符
  static final englishRegex = RegExp('[\x20-\x7E\\\\]');

  static late final XLoggerConfig _config;

  static Future<bool> init(XLoggerConfig config) {
    try {
      _config.aesIv;
      debugPrint('已经初始化过了，不需要再次初始化');
      return Future.value(true);
    } catch (error) {
      _config = config;
      return _FlutterLogan.init(config.aseKey, config.aesIv, config.maxFileLength);
    }
  }

  ///返回给定时间对应的日志文件地址
  static Future<File> getLog(DateTime date) async {
    String time = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final String path = await _FlutterLogan.getUploadPath(time);
    return File(path);
  }

  static Future<bool> deleteLog(DateTime dateTime) async {
    File file = await getLog(dateTime);
    if (!file.existsSync()) {
      return false;
    }
    file.deleteSync();
    return true;
  }

  static Future<List<File>> getAllLogs() async {
    final List<String> paths = await _FlutterLogan.getAllLogs();
    List<File> fileList = [];
    for (var s in paths) {
      File file = File(s);
      if (file.existsSync()) {
        fileList.add(file);
      }
    }
    return fileList;
  }

  static Future<void> flush() async {
    await _FlutterLogan.flush();
  }

  static Future<void> cleanAllLogs() async {
    await _FlutterLogan.cleanAllLogs();
  }

  static Future<void> v(dynamic content, {bool? saveToFile, String? tag}) {
    return _printLog(Level.V, _config.getVerbaseColor(), tag, content, saveToFile, StackTrace.current);
  }

  static Future<void> d(dynamic content, {bool? saveToFile, String? tag}) {
    return _printLog(Level.D, _config.getDebugColor(), tag, content, saveToFile, StackTrace.current);
  }

  static Future<void> i(dynamic content, {bool? saveToFile, String? tag}) {
    return _printLog(Level.I, _config.getInfoColor(), tag, content, saveToFile, StackTrace.current);
  }

  static Future<void> w(dynamic content, {bool? saveToFile, String? tag}) {
    return _printLog(Level.W, _config.getWarningColor(), tag, content, saveToFile, StackTrace.current);
  }

  static Future<void> e(dynamic content, {bool? saveToFile, String? tag}) {
    return _printLog(Level.E, _config.getErrorColor(), tag, content, saveToFile, StackTrace.current);
  }

  static Future<void> _printLog(
      Level level, XLoggerColor color, String? tag, dynamic content, bool? saveToFile, StackTrace stackTrace) async {
    saveToFile ??= _config.enableSave;
    if (saveToFile) {
      try {
        await _FlutterLogan.log(1, content);
      } catch (error) {
        debugPrint(error.toString(), wrapWidth: 125);
      }
    }
    if (!_config.enablePrint) {
      return;
    }
    if (_config.filter != null) {
      bool filt = _config.filter!.filter(level, content, tag);
      if (filt) {
        return;
      }
    }

    List<String> list = _handleLog(_stringifyMessage(content), tag, stackTrace);
    for (var s in list) {
      print("${color.getStrPre()}$s${XLoggerColor.ansiDefault}");
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

  //生成对应的行数据
  static List<String> _handleLog(String log, String? tag, StackTrace stackTrace) {
    List<String> contentList = _splitLargeLog(log, _config.lineMaxLength); //日志数据
    List<String> stackTraceList = _getStrackInfo(stackTrace, _config.staticOffset, _config.methodCount); //帧栈数据

    //计算分割线的宽度
    int diverLength = 0;
    for (var element in contentList) {
      if (element.length > diverLength) {
        diverLength = element.length;
      }
    }
    for (var element in stackTraceList) {
      if (element.length > diverLength) {
        diverLength = element.length;
      }
    }
    diverLength += 4;
    if (diverLength > _config.lineMaxLength + 4) {
      diverLength = _config.lineMaxLength + 4;
    }

    //数据拼接
    List<String> resultList = List.empty(growable: true);
    //临时处理字符
    StringBuffer buffer = StringBuffer(_topLeftCorner);

    //添加顶部分割线
    for (int i = 0; i < diverLength; i++) {
      buffer.write(_doubleDivider);
    }
    resultList.add(buffer.toString());
    buffer.clear();

    //处理 Tag
    if (tag != null && tag.isNotEmpty) {
      resultList.add(_verticalLine + "TAG: $tag");
      buffer.write(_middleCorner);
      for (int i = 0; i < diverLength; i++) {
        buffer.write('─');
      }
      resultList.add(buffer.toString());
      buffer.clear();
    }

    //添加帧栈内容
    if (stackTraceList.isNotEmpty) {
      for (var value in stackTraceList) {
        resultList.add(_verticalLine + value);
      }
      //添加内容和帧栈之间的分割线
      buffer.write(_middleCorner);
      for (int i = 0; i < diverLength; i++) {
        buffer.write('─');
      }
      resultList.add(buffer.toString());
      buffer.clear();
    }

    //添加日志内容和实际的行分割
    for (var s in contentList) {
      resultList.add("$_verticalLine $s");
    }
    //添加底部分割线
    buffer.write(_bottomLeftCorner);
    for (int i = 0; i < diverLength; i++) {
      buffer.write(_doubleDivider);
    }
    resultList.add(buffer.toString());
    return resultList;
  }

  //解析调用栈并生成对应样式字符串列表
  static List<String> _getStrackInfo(StackTrace trace, int methodOffset, int methodCount) {
    if (methodOffset < 0) {
      methodOffset = 0;
    }
    if (methodCount <= 0) {
      methodCount = 1;
    }
    var chain = Chain.forTrace(trace);
    int offset = methodOffset;
    List<Frame> frameList = [];
    for (var value in chain.traces) {
      for (var v2 in value.frames) {
        //过滤掉自身的
        if (v2.location.contains('xlogger/xlogger.dart')) {
          continue;
        }
        if (offset <= 0) {
          frameList.add(v2);
        }
        offset--;
        if (frameList.length >= methodCount) {
          break;
        }
      }
      if (frameList.length >= methodCount) {
        break;
      }
    }
    List<String> resultList = [];
    int tabCount = 0;

    for (int i = 0; i < frameList.length; i++) {
      var element = frameList[i];
      String line = element.library;
      if (element.line != null) {
        line += ' ${element.line}';
      }
      String s;
      if (element.member != null) {
        s = "${element.member}($line)";
      } else {
        s = line;
      }

      for (int j = 0; j < tabCount; j++) {
        s = " " + s; //这里没用\t 是避免多个\t造成的间距过大
      }
      resultList.add(s.replaceAll("\n", ''));
      tabCount++;
    }
    return resultList;
  }

  //分割日志
  static List<String> _splitLargeLog(String log, int lineMax) {
    List<String> lineList = List.empty(growable: true); //存储分割后处理的数据
    List<String> tempList = log.split(RegExp('\n')); //先按照换行符分割数据
    RegExp tabReg = RegExp("\t");
    int maxLength = 0; //记录日志中最长行的宽度
    for (var s in tempList) {
      int sl = s.length;
      if (sl <= lineMax) {
        lineList.add(s);
        if (sl > maxLength) {
          maxLength = sl;
          Iterable<RegExpMatch> matchs = tabReg.allMatches(s);
          int tSize = matchs.length;
          maxLength += (tSize * 4); //Tab 长度4个字符
        }
        continue;
      }
      String tempS = s;
      while (true) {
        if (tempS.length <= lineMax ~/ 2) {
          lineList.add(tempS);
          tempS = '';
          break;
        }

        List tL = _computeSpliIndex(tempS, lineMax);
        String sp = tL[0];
        lineList.add(sp);
        if (sp.length == tempS.length) {
          break;
        }
        tempS = tempS.substring(sp.length);
        if (maxLength < tL[1]) {
          maxLength = tL[1];
          Iterable<RegExpMatch> matchs = tabReg.allMatches(sp);
          int tSize = matchs.length;
          maxLength += (tSize * 4);
        }
      }

      while (tempS.length > lineMax) {}
      if (tempS.isNotEmpty) {
        lineList.add(tempS);
      }
    }
    return lineList;
  }

  ///计算符合切割要求的位置(一个中文字符占2个位置，一个emoji等于一个中文字符宽度)
  ///[s] 待分割字符串；[max]每行最多好多个字符
  ///返回值[0] 为对应的字符串 [1]为字符串长度
  static List _computeSpliIndex(String s, int max) {
    Characters characters = s.characters;
    if (characters.length <= max ~/ 2) {
      return [s, computeVirtualLength(s)];
    }

    String pre = characters.getRange(0, max ~/ 2 + 1).toString();
    int realLength = computeVirtualLength(pre); //当前实时长度
    int index = max ~/ 2 + 1;
    while (realLength < max && index < characters.length) {
      int remainCount = max - realLength;
      if (remainCount >= 2) {
        int oldIndex = index;
        index += (remainCount ~/ 2 + 1);
        String nodeStr = characters.getRange(oldIndex, index + 1).toString();
        realLength += computeVirtualLength(nodeStr);
      } else {
        if (remainCount == 1) {
          if (englishRegex.hasMatch(characters.elementAt(index + 1))) {
            index += 1;
            realLength += 1;
            break;
          } else {
            break;
          }
        } else {
          break;
        }
      }
    }

    if (index >= 0 && index < characters.length) {
      return [characters.getRange(0, index + 1).toString(), realLength];
    }
    return [s, computeVirtualLength(s)];
  }

  ///计算字符串虚拟长度
  static int computeVirtualLength(String s) {
    int englishCount = englishRegex.allMatches(s).length;
    return s.characters.length * 2 - englishCount;
  }
}

abstract class PrintFilter {
  bool filter(Level level, dynamic content, String? tag);
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

  static Future<List<String>> getAllLogs() async {
    final List<Object?> result = await _channel.invokeMethod('getAllLogs');
    List<String> list = [];
    for (int i = 0; i < result.length; i++) {
      Object? obj = result[i];
      if (obj == null) {
        continue;
      }
      list.add(obj.toString());
    }
    return list;
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
