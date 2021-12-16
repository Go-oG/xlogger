import 'dart:math';

import 'package:flutter/material.dart';
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
    XLogger.init("1111111122222222", '1111111122222222');
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
                  XLogger.d("这是Debug级别日志", saveToFile: true);
                },
                child: const Text('pD')),
            ElevatedButton(
                onPressed: () {
                  XLogger.i("这是Info级别日志", saveToFile: true);
                },
                child: const Text('pI')),
            ElevatedButton(
                onPressed: () {
                  XLogger.w("这是Warning级别日志", saveToFile: true);
                },
                child: const Text('pW')),
            ElevatedButton(
                onPressed: () {
                  XLogger.e("这是Error级别日志", saveToFile: true);
                },
                child: const Text('pE')),
            ElevatedButton(
                onPressed: () {
                  StringBuffer bu = StringBuffer('超大日志');
                  Random random = Random();
                  List<String> list = [
                    'a',
                    'b',
                    'c',
                    'd',
                    'e',
                    'f',
                    'g',
                    'h',
                    'i',
                    'j',
                    'k',
                    'l',
                    'm',
                    'n',
                    'o',
                    'p',
                    'q',
                    'r',
                    's',
                    't',
                    'u',
                    'v',
                    'w',
                    'x',
                    'y',
                    'z',
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '0',
                    'A',
                    'B',
                    'C',
                    'D',
                    'E',
                    'F',
                    'G',
                    'H',
                    'I',
                    'J',
                    'K',
                    'L',
                    'M',
                    'N',
                    'O',
                    'P',
                    'Q',
                    'R',
                    'S',
                    'T',
                    'U',
                    'V',
                    'W',
                    'X',
                    'Y',
                    'Z'
                  ];
                  for (int i = 0; i < 1024 * 9; i++) {
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
            ElevatedButton(
                onPressed: () {
                  XLogger.cleanAllLogs();
                },
                child: const Text('clearAll')),
          ],
        ),
      ),
    );
  }
}
