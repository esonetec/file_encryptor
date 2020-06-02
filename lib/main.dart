import 'dart:async';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ListViews',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('ListViews')),
        body: ListWidget(),
      ),
    );
  }
}

class ListWidget extends StatefulWidget {

  const ListWidget({
    Key key,
  }) : super(key: key);

  FileList createState() => FileList();

}

class FileList extends State<ListWidget> {

  // Platform messages are asynchronous, so we initialize in an async method.
  requestWritePermission() async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }
  }

  Future<List<FileSystemEntity>> loadFiles() async {
    await requestWritePermission();

    final myDir = new Directory("/storage/emulated/0/Download");
    var list = myDir.list().listen((FileSystemEntity entity) {
      print(entity.path);
    });
    return new Future(() => []);
  }

  @override
  Widget build(BuildContext context) {
      return new FutureBuilder<List<FileSystemEntity>>(
      future: loadFiles(),
      builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
        if (snapshot.hasData) {
          return _myListView(context, snapshot.data);
        } else {
          var children = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        }

      },
    );
  }

}

Widget _myListView(BuildContext context, List<FileSystemEntity> files) {

  return ListView.builder(
    itemCount: files.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(files[index].path),
        onTap: () {
          final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
          final key = encrypt.Key.fromUtf8('my 32 length key................');
          final iv = encrypt.IV.fromLength(16);

          final encrypter = encrypt.Encrypter(encrypt.AES(key));

          final encrypted = encrypter.encrypt(plainText, iv: iv);
          final decrypted = encrypter.decrypt(encrypted, iv: iv);

          print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
          print(encrypted.base64); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==

          print(files[index].path);
        },
      );
    },
  );

}

