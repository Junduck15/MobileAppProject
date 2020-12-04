import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';
import 'package:mobileappproject/main.dart';

import 'add.dart';

class Problems_infolderPage extends StatefulWidget {
  final String foldername;

  Problems_infolderPage({Key key, @required this.foldername}) : super(key: key);

  @override
  _Problems_infolderPage createState() => _Problems_infolderPage();
}

class _Problems_infolderPage extends State<Problems_infolderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int a;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection(widget.foldername);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.foldername,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                  child: Column(children: <Widget>[
        SizedBox(height: 20.0),
        Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, stream) {
                  if (stream.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (stream.data == null) return CircularProgressIndicator();

                  if (stream.hasError) {
                    return Center(child: Text(stream.error.toString()));
                  } else
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: stream.data.size,
                      itemBuilder: (BuildContext context, int index) {
                        a = index;
                        return Container(
                            padding: EdgeInsets.only(top: 3),
                            child: Card(
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: maincolor, width: 2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 20.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              stream
                                                              .data.docs[index]
                                                          ['isMultiple'] ==
                                                      false
                                                  ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children : <Widget> [
                                                  Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children : <Widget> [
                                                        Text('Q.',style : TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color : maincolor,)),
                                                        SizedBox(height: 5,),
                                                        Padding(
                                                            padding: EdgeInsets.fromLTRB(20, 9, 20, 10),
                                                            child : Text(
                                                                stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                                style: TextStyle(
                                                                  fontSize: 17,
                                                                ))
                                                        )

                                                      ]
                                                  )


                                                ]

                                              )

                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                          Text(
                                                              '문제. ' +
                                                                  '\n\n  ' +
                                                                  stream.data.docs[
                                                                          index]
                                                                      [
                                                                      'problemtext'],
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                              )),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Divider(
                                                            height: 1.0,
                                                            color: maincolor,
                                                            indent: 0,
                                                            endIndent: 0,
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(
                                                              '1)  ' +
                                                                  stream.data.docs[
                                                                          index]
                                                                      [
                                                                      'multipleWrongAnswers'][0],
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                              )),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                              '2)  ' +
                                                                  stream.data.docs[
                                                                          index]
                                                                      [
                                                                      'multipleWrongAnswers'][1],
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                              )),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                              '3)  ' +
                                                                  stream.data.docs[
                                                                          index]
                                                                      [
                                                                      'multipleWrongAnswers'][2],
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                              )),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                              '4)  ' +
                                                                  stream.data.docs[
                                                                          index]
                                                                      [
                                                                      'answer'],
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                              )),
                                                        ])
                                            ]),
                                      )
                                    ])));
                      },
                    );
                }))
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
