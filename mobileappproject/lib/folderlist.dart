import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:mobileappproject/main.dart';
import 'dart:io';
import 'package:path/path.dart';

import 'profile.dart';

import 'add.dart';
import 'package:mobileappproject/login.dart';

class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<dynamic> problemTypes = [];

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
      body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                  child: Column(children: <Widget>[
        SizedBox(height: 20.0),
        Container(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(_auth.currentUser.uid)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                snapshot.data.data()["problemTypes"] != null
                    ? problemTypes = snapshot.data.data()["problemTypes"]
                    : problemTypes = [];
              }

              return GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Card(
                    //color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: maincolor, width: 2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  (problemTypes[index]),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                ),
                                SizedBox(height: 10.0),
                                Divider(height: 1.0,color : maincolor,indent: 10, endIndent: 10,),
                                SizedBox(height: 15.0),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('    문제 수 : ', style: TextStyle(fontSize: 17,)),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
                },
                itemCount: problemTypes.length,
              );
            },
          ),
        )
      ])))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add()));
        },
        child: Icon(Icons.add),
        backgroundColor: maincolor,
      ),
    );
  }
}
