# xlogger

轻量、美观强大的Flutter日志库，可同时将日志打印在如 Logcat、Console 和文件(MMKV)中。
支持超大字符串、自定义日志颜色、是否保存到本地等功能

# Input

## Getting Started

## Install
在你的 pubspec.yaml 文件中添加以下代码
'''

'''
## Init
'''
@override
void initState() { 
  super.initState();
  // the aesKey and aesIv length always 16
  XLogger.init(XLoggerConfig('aesKey', 'aesIv', true, false));
}
'''
## Use

'''
//print Debug Log
XLogger.d("debug log", saveToFile: false,tag:"LogTag");

//print Info Log
XLogger.i("debug log", saveToFile: false,tag:"LogTag");

//print Warning Log
XLogger.w("debug log", saveToFile: false,tag:"LogTag");

//print Error Log
XLogger.e("debug log", saveToFile: false,tag:"LogTag");

//print Verbose Log
XLogger.v("debug log", saveToFile: false,tag:"LogTag");

在 所有方法中 saveToFile 和 tag 是可选的；saveToFile default false  tag default is Null;
'''

## Other Config
其它高级配置请查看XloggerConfig代码




