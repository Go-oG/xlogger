import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xlogger/log_parser.dart';
import 'package:xlogger/xlogger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    XLogger.init(XLoggerConfig('0000111100001111', '0000111100001111', true, true));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 36),
            ElevatedButton(
                onPressed: () {
                  XLogger.d("This is the Debug Level Log", saveToFile: true);
                  XLogger.flush();
                },
                child: const Text('pD')),
            ElevatedButton(
                onPressed: () async {
                  await XLogger.i(
                    "This is the info Level Log",
                  );
                  XLogger.flush();
                },
                child: const Text('pI')),
            ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> json = {};
                  json["key1"] = "test1";
                  json["Key2"] = 1;
                  json["key3"] = 2.30;
                  json["key4"] = true;
                  Map<String, dynamic> child = {};
                  child['childKey1'] = "child";
                  child['childKey2'] = 234;
                  json['key5'] = child;
                  XLogger.w(json, saveToFile: true, tag: "MainDart");
                },
                child: const Text('pjson')),
            ElevatedButton(
                onPressed: () async {
                  StringBuffer bu = StringBuffer();
                  Random random = Random();
                  List<String> list = [
                    'abcd',
                    '😀😃😄😁'
                        '测试Large',
                  ];
                  for (int i = 0; i < 46; i++) {
                    int index = (random.nextDouble() * list.length).toInt();
                    if (index >= list.length) {
                      index = list.length - 1;
                    }
                    bu.write(list[index]);
                  }
                  await XLogger.w(bu.toString(), saveToFile: true);
                  XLogger.flush();
                },
                child: const Text('large')),
            ElevatedButton(
                onPressed: () {
                  XLogger.cleanAllLogs();
                },
                child: const Text('Clear')),
            ElevatedButton(
                onPressed: () async {
                  List<File> list = await XLogger.getAllLogs();
                  if (list == null || list.isEmpty) {
                    print("暂无相关日志");
                    return;
                  }
                  String s = await LoganParser('0000111100001111', '0000111100001111').parse(list[list.length - 1]);
                  print('解密日志：\n$s');
                },
                child: const Text('Parse'))
          ],
        ),
      ),
    );
  }
}
