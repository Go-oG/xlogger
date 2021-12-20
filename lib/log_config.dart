import 'package:flutter/cupertino.dart';
import 'package:xlogger/xlogger.dart';

import 'xlogger_color.dart';

class XLoggerConfig {
  static final XLoggerColor _v = XLoggerColor.rgb(187, 187, 187);
  static final XLoggerColor _d = XLoggerColor.rgb(37, 188, 36);
  static final XLoggerColor _i = XLoggerColor.rgb(255, 255, 0);
  static final XLoggerColor _w = XLoggerColor.rgb(255, 85, 85);
  static final XLoggerColor _e = XLoggerColor.rgb(187, 0, 0);

  XLoggerColor _verbaseColor = _v;
  XLoggerColor _debugColor = _d;
  XLoggerColor _infoColor = _i;
  XLoggerColor _warningColor = _w;
  XLoggerColor _errorColor = _e;

  PrintFilter? _filter;

  int _stackOffset = 0;
  int _methodCount = 2;
  int _lineMaxLengtn = 120; //每行最多显示多少
  int _maxFileLength = 2 * 1024 * 1024 * 1024;

  final String aseKey;
  final String aesIv;

  bool _enablePrint;
  bool _enableSave;

  XLoggerConfig(this.aseKey, this.aesIv, this._enablePrint,this._enableSave);

  set verbaseColor(Color color) {
    _verbaseColor = XLoggerColor.color(color);
  }

  set debugColor(Color color) {
    _debugColor = XLoggerColor.color(color);
  }

  set infoColor(Color color) {
    _infoColor = XLoggerColor.color(color);
  }

  set warningColor(Color color) {
    _warningColor = XLoggerColor.color(color);
  }

  set errorColor(Color color) {
    _errorColor = XLoggerColor.color(color);
  }


  XLoggerColor getVerbaseColor() {
    return _verbaseColor;
  }

  XLoggerColor getDebugColor() {
    return _debugColor;
  }

  XLoggerColor getInfoColor() {
    return _infoColor;
  }

  XLoggerColor getWarningColor() {
    return _warningColor;
  }

  XLoggerColor getErrorColor() {
    return _errorColor;
  }

  set filter(filter) {
    _filter = filter;
  }

  PrintFilter? get filter => _filter;

  set stackOffset(int offset) {
    _stackOffset = offset;
  }

  int get staticOffset => _stackOffset;

  set methodCount(count) {
    _methodCount = count;
  }

  int get methodCount => _methodCount;

  set lineMaxLength(maxLen) {
    _lineMaxLengtn = maxLen;
  }

  int get lineMaxLength => _lineMaxLengtn;

  set maxFileLength(maxLen) {
    _maxFileLength = maxLen;
  }

  int get maxFileLength => _maxFileLength;

  set enablePrint(enableValue){
    _enablePrint=enableValue;
  }

  bool get enablePrint =>_enablePrint;

  set enableSave(enableValue){
    _enableSave=enableValue;
  }

  bool get enableSave =>_enableSave;

}
