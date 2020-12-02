
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

import 'profile.dart';

import 'add.dart' ;
import 'package:mobileappproject/login.dart';

class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

    Query query = FirebaseFirestore.instance.collection('users');

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
              size: 28,
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
        child: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, stream) {
            if (stream.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (stream.hasError) {
              return Center(child: Text(stream.error.toString()));
            }

            if (stream.data == null)
              return CircularProgressIndicator();

            QuerySnapshot querySnapshot = stream.data;

            return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              18.0, 12.0, 0.0, 8.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                ('ss'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                              SizedBox(height: 5.0),

                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                        textColor: Colors.blue,
                                        child: Text(
                                          'more',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        onPressed: () {

                                        }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: querySnapshot.size,
            );
          },
        ),
      ),
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
