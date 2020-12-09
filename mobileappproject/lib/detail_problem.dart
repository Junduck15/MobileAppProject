import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/edit_problem.dart';
import 'package:mobileappproject/login.dart';
import 'package:mobileappproject/main.dart';
import 'package:translator/translator.dart';

import 'add.dart';

class Detail_problemPage extends StatefulWidget {
  final String foldername;
  final String problemid;

  Detail_problemPage({Key key, @required this.foldername, this.problemid})
      : super(key: key);

  @override
  _Detail_problemPageState createState() => _Detail_problemPageState();
}

class _Detail_problemPageState extends State<Detail_problemPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String out = "";
  String korean = "";
  String problemtext;
  String answer;
  bool isMulti;
  String mul1;
  String mul2;
  String mul3;

  @override
  Widget build(BuildContext context) {
    trans(String pro_text) async {
      final translator = GoogleTranslator();

      var translation = await translator.translate(pro_text, to: 'ko');

      out = translation.toString();
      // prints Dart jest bardzo fajny!

      return out;
      // prints exemplo
    }

    void _hi(String pro_text) async {
      String a = await trans(pro_text);
      setState(() {
        out = a;
        korean = "[한국어]";
      });
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '문제',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    semanticLabel: 'edit product',
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Edit_ProblemPage(
                              foldername: widget.foldername,
                              problemid: widget.problemid,
                              problem: problemtext,
                              answer : answer,
                            isMulti: isMulti,
                            mul1: mul1,
                            mul2: mul2,
                            mul3: mul3,
                          )),
                    );
                  },
                );
              },
            ),
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                  semanticLabel: 'delete product',
                ),
                onPressed: () {
                  Navigator.pop(context);
                  deleteDoc(widget.foldername, widget.problemid);
                },
              );
            }),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser.uid)
                .collection(widget.foldername)
                .doc(widget.problemid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              if (snapshot.data == null) {
                return CircularProgressIndicator();
              } else {
                problemtext = snapshot.data['problemtext'];
                answer = snapshot.data['answer'];
                isMulti = snapshot.data['isMultiple'];
                if (isMulti == true) {
                  mul1 = snapshot.data['multipleWrongAnswers'][0];
                  mul2 = snapshot.data['multipleWrongAnswers'][1];
                  mul3 = snapshot.data['multipleWrongAnswers'][2];
                }
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(30.0, 30.0, 15.0, 20.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              snapshot.data['isMultiple'] == false
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                          Container(
                                            height: 25.0,
                                            width: 65,
                                            color: Colors.transparent,
                                            child: new Container(
                                                decoration: new BoxDecoration(
                                                  color: Colors.orangeAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: new Center(
                                                  child: new Text("주관식",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                )),
                                          ),
                                          //Text(await trans()),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Q.',
                                                    style: TextStyle(
                                                      fontSize: 27,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: maincolor,
                                                    )),
                                                Flexible(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 9, 20, 10),
                                                        child: Text(
                                                            snapshot.data[
                                                                'problemtext'],
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                            ))))
                                              ]),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Divider(
                                            height: 1.0,
                                            color: maincolor,
                                            indent: 40,
                                            endIndent: 20,
                                          ),
                                          SizedBox(
                                            height: 25,
                                          ),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('A.',
                                                    style: TextStyle(
                                                      fontSize: 27,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: maincolor,
                                                    )),
                                                Flexible(
                                                    child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 9, 20, 15),
                                                  child: Text(
                                                      snapshot.data['answer'],
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.redAccent,
                                                      )),
                                                ))
                                              ]),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                    snapshot.data['createdTime']
                                                        .toDate()
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                Text(' 에 등록됨 ',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey)),
                                              ]),
                                        ])
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                          Container(
                                            height: 25.0,
                                            width: 65,
                                            color: Colors.transparent,
                                            child: new Container(
                                                decoration: new BoxDecoration(
                                                  color: Colors.lightGreen,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: new Center(
                                                  child: new Text("객관식",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                )),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Q.',
                                                    style: TextStyle(
                                                      fontSize: 27,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: maincolor,
                                                    )),
                                                Flexible(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 9, 20, 15),
                                                        child: Text(
                                                            snapshot.data[
                                                                'problemtext'],
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                            ))))
                                              ]),
                                          Container(
                                            margin: EdgeInsets.only(left: 235),
                                            width: 103,
                                            child: OutlineButton(
                                              color: maincolor,
                                              focusColor: maincolor,
                                              highlightElevation: 0.5,
                                              child: Row(children: <Widget>[
                                                Icon(
                                                  Icons.g_translate,
                                                  size: 17,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  '번역하기',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ]),
                                              onPressed: () {
                                                _hi(snapshot
                                                    .data['problemtext']);
                                              },
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  38, 9, 45, 10),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      korean,
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                    Text(out,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                        )),
                                                  ])),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            height: 1.0,
                                            color: maincolor,
                                            indent: 40,
                                            endIndent: 20,
                                          ),
                                          SizedBox(
                                            height: 25,
                                          ),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('A.',
                                                    style: TextStyle(
                                                      fontSize: 27,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: maincolor,
                                                    )),
                                                Flexible(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 9, 20, 15),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Text(
                                                                  '1)    ' +
                                                                      snapshot.data[
                                                                              'multipleWrongAnswers']
                                                                          [0],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  )),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                  '2)   ' +
                                                                      snapshot.data[
                                                                              'multipleWrongAnswers']
                                                                          [1],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  )),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                  '3)   ' +
                                                                      snapshot.data[
                                                                              'multipleWrongAnswers']
                                                                          [2],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  )),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                  '4)   ' +
                                                                      snapshot.data[
                                                                          'answer'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    color: Colors
                                                                        .redAccent,
                                                                  )),
                                                            ])))
                                              ]),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                    snapshot.data['createdTime']
                                                        .toDate()
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                Text(' 에 등록됨 ',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey)),
                                              ]),
                                        ])
                            ]),
                      )
                    ]);
              }
            }));
  }

  void deleteDoc(String folder, String problemId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection(folder)
        .doc(problemId)
        .delete();
  }
}
