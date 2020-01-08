import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  initState() {
    super.initState();

    _loadValues();
  }

  void _wake() async {
    var destAddr = InternetAddress("255.255.255.255");

    await RawDatagramSocket.bind(InternetAddress.anyIPv4, 9)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.broadcastEnabled = true;
      Uint8List data = Uint8List(6 + 16 * 6);
      var addr = 0x4cedfb3f0b45;
      addr = int.parse(_macController.text, radix: 16);
      for (var i = 0; i < 6; i++) {
        data[i] = 0xff;
      }
      for (int i = 6; i < data.length; i += 6) {
        for (int j = 0; j < 6; j++) {
          data[i + j] = (addr >> (5 - j) * 8) & 0xff;
        }
      }
      udpSocket.send(data, destAddr, 9);
    }).catchError((err) {
      print('help');
    });
    _saveValues(null);
  }

  var _macController = TextEditingController(text: '4cedfb3f0b45');
  var _broadcastController = TextEditingController(text: '255.255.255.255');

  _saveValues(s) async {
    Directory d = await getApplicationDocumentsDirectory();
    File f = File(d.path + '/saved.dat');
    f.writeAsString(
      '${_macController.text}Z${_broadcastController.text}',
      mode: FileMode.write,
    );
  }

  _loadValues() async {
    Directory d = await getApplicationDocumentsDirectory();
    File f = File(d.path + '/saved.dat');
    if (f.existsSync()) {
      var x = f.readAsStringSync().split('Z');
      setState(() {
        _macController.text = x[0];
        _broadcastController.text = x[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _macController,
              decoration: InputDecoration.collapsed(hintText: 'Mac Address'),
              onChanged: _saveValues,
            ),
            TextField(
              controller: _broadcastController,
              decoration:
                  InputDecoration.collapsed(hintText: 'Broadcast Address'),
              onChanged: _saveValues,
            ),
            RaisedButton(child: Text('Send it'), onPressed: _wake),
          ],
        ),
      ),
    );
  }
}
