
import 'dart:ui';

class XLoggerColor {
  static const ansiEsc = '\x1B[38;2;';
  static const ansiDefault = '\x1B[0m';
  late final int r;
  late final int g;
  late final int b;

  XLoggerColor.rgb(this.r, this.g, this.b);

  XLoggerColor.color(Color color) {
    r = color.red;
    g = color.green;
    b = color.blue;
  }

  String getStrPre() {
    return "$ansiEsc$r;$g;${b}m";
  }

}