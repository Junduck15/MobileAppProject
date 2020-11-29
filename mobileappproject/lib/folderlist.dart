
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profile.dart';

import 'add.dart' ;
import 'package:mobileappproject/login.dart';

class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
        height: 32,
        child: Image.network(
          'https://ifh.cc/g/b7RiPf.png',
        ),
      ),
              leading: IconButton(
            icon: Icon(
              Icons.perm_identity,
              color: Colors.white,
              semanticLabel: 'menu',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
      ),
      body: Container(
          margin: EdgeInsets.fromLTRB(85, 30, 0, 10),
          child: Text('사용자 폴더 보여주는 페이지')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
              Add()));
        },
        child: Icon(Icons.add),
        backgroundColor: maincolor,
      ),
    );
  }
}
