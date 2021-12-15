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
    XLogger.init("0102030405060708", '0102030405060708');
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
                  XLogger.getLog(DateTime.now()).then((value) {
                    print("获取今天日志：${value.path}");
                  });
                },
                child: const Text('get')),
            ElevatedButton(
                onPressed: () {
                  XLogger.getAllLogs().then((value) {
                    StringBuffer buffer=StringBuffer("获取所有日志\n");
                    for (var element in value) {
                      buffer..write(element.path)..write("\n");
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
