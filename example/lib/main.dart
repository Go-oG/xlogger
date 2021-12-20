import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xlogger/xlogger.dart';
import 'package:xlogger_example/log_util.dart';

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
    XLogger.init(XLoggerConfig('0000111100001111', '0000111100001111', true, false));
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
                },
                child: const Text('pD')),
            ElevatedButton(
                onPressed: () {
                  LogUtil.i(
                    "This is the info Level Log",
                  );
                },
                child: const Text('pI')),
            ElevatedButton(
                onPressed: () {
                  Map<String,dynamic> json={};
                  json["key1"]="test1";
                  json["Key2"]=1;
                  json["key3"]=2.30;
                  json["key4"]=true;
                  Map<String,dynamic> child={};
                  child['childKey1']="child";
                  child['childKey2']=234;
                  json['key5']=child;
                  XLogger.w(json, saveToFile: true, tag: "MainDart");
                },
                child: const Text('pW')),
            ElevatedButton(
                onPressed: () {
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
                  XLogger.w(bu.toString());
                },
                child: const Text('large')),
            ElevatedButton(
                onPressed: () {
                  XLogger.getAllLogs().then((value) {
                    StringBuffer buffer = StringBuffer("获取所有日志\n");
                    for (var element in value) {
                      buffer
                        ..write(element.path)
                        ..write("\n");
                    }
                    print(buffer.toString());
                  });
                },
                child: const Text('getAll')),
          ],
        ),
      ),
    );
  }
}
