import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';

class BankPage extends StatefulWidget {
  @override
  _BankPage createState() => _BankPage();
}

class _BankPage extends State<BankPage> {
  List<dynamic> problemTypes = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var problemType;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Query query = FirebaseFirestore.instance.collection('생활영어');
    Query query2 = FirebaseFirestore.instance.collection('토익');
    Query query3 = FirebaseFirestore.instance.collection('토플');
    Query query4 = FirebaseFirestore.instance.collection('기타');

    Future getprobtype() async {
      await firestore
          .collection('users')
          .doc(_auth.currentUser.uid)
          .get()
          .then((DocumentSnapshot ds) {
        problemTypes = ds['problemTypes'];
      });
    }

    void _showDialog2() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final newTypeController = TextEditingController();
          return AlertDialog(
            title: Text("문제 그룹 생성"),
            content: Container(
              height: 80,
              child: Column(
                children: [
                  Text("생성할 문제 그룹 이름을 입력해주세요."),
                  TextField(
                    controller: newTypeController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("생성"),
                onPressed: () {
                  firestore
                      .collection('users')
                      .doc(_auth.currentUser.uid)
                      .update({
                    "problemTypes":
                        FieldValue.arrayUnion([newTypeController.text]),
                  });
                  firestore
                      .collection('users')
                      .doc(_auth.currentUser.uid)
                      .collection('problemType');
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    Widget _body(BuildContext context, QueryDocumentSnapshot doc) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Form(
              key: _formKey,
              child: AlertDialog(
                  title: Text("문제 그룹 지정"),
                  actions: [
                    FlatButton(
                      child: Text(
                        "취소",
                        style: TextStyle(fontSize: 16, color: Colors.black38),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          problemType = null;
                        });
                      },
                    ),
                    FlatButton(
                        child: Text(
                          "담기",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Navigator.pop(context);

                            //problemTypes.add(doc['problemtype']);

                            firestore
                                .collection('users')
                                .doc(_auth.currentUser.uid)
                                .update({
                              "problemTypes":
                                  FieldValue.arrayUnion(problemTypes),
                            });
                            DocumentReference ref = FirebaseFirestore.instance
                                .collection('users')
                                .doc(_auth.currentUser.uid)
                                .collection(problemType)
                                .doc();

                            doc['isMultiple'] == false
                                ? ref.set({
                                    'problemtext': doc['problemtext'],
                                    'answer': doc['answer'],
                                    'picture': doc['picture'],
                                    'creator': doc['creator'],
                                    'isShared': doc['isShared'],
                                    'createdTime': FieldValue.serverTimestamp(),
                                    'isMultiple': false,
                                    'problemtype': problemType,
                                    'id': ref.id,
                                  })
                                : ref.set({
                                    'problemtext': doc['problemtext'],
                                    'answer': doc['answer'],
                                    'multipleWrongAnswers':
                                        doc['multipleWrongAnswers'],
                                    'picture': doc['picture'],
                                    'creator': doc['creator'],
                                    'isShared': doc['isShared'],
                                    'createdTime': FieldValue.serverTimestamp(),
                                    'isMultiple': false,
                                    'problemtype': problemType,
                                    'id': ref.id,
                                  });
                          }
                          setState(() {
                            problemType = null;
                          });
                        }),
                  ],
                  content: Container(
                      height: 150,
                      child: Column(
                        children: [
                          Container(
                              child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(5, 20, 0, 0),
                                  child: FormField<String>(
                                    builder: (FormFieldState<String> state) {
                                      return InputDecorator(
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5.0))),
                                        child: DropdownButtonHideUnderline(
                                          child:
                                              DropdownButtonFormField<String>(
                                            hint: Text("문제그룹"),
                                            value: problemType,
                                            isDense: true,
                                            isExpanded: true,
                                            onChanged: (newValue) {
                                              setState(() {
                                                problemType = newValue;
                                              });
                                            },
                                            items: problemTypes
                                                .map((dynamic value) {
                                              return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,
                                                      overflow:
                                                          TextOverflow.fade));
                                            }).toList(),
                                            validator: (value) => value == null
                                                ? '문제 그룹을 선택하지 않았습니다.'
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                  width: 70,
                                  height: 70,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  child: Column(children: <Widget>[
                                    FlatButton(
                                      child: Icon(
                                        Icons.add,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        _showDialog2();
                                      },
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '그룹 추가',
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    )
                                  ])),
                            ],
                          )),
                        ],
                      ))));
        },
      );
    }

    Widget _lifeEng(BuildContext context) {
      return Container(
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
                          return Container(
                              padding: EdgeInsets.only(top: 3),
                              child: Card(
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    side:
                                        BorderSide(color: maincolor, width: 2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20.0, 0.0, 15.0, 13.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                stream.data.docs[index]
                                                            ['isMultiple'] ==
                                                        false
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            32,
                                                                            9,
                                                                            20,
                                                                            10),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      Divider(
                                                                        height:
                                                                            1.0,
                                                                        color:
                                                                            maincolor,
                                                                        indent:
                                                                            0,
                                                                        endIndent:
                                                                            0,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      Text(
                                                                          '1)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  0],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '2)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  1],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '3)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  2],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '4)  ' +
                                                                              stream.data.docs[index][
                                                                                  'answer'],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                    ])),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                              ]),
                                        )
                                      ])));
                        });
                }))
      ]));
    }

    ;
    Widget _toeic(BuildContext context) {
      return Container(
          child: Column(children: <Widget>[
        SizedBox(height: 20.0),
        Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: query2.snapshots(),
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
                          return Container(
                              padding: EdgeInsets.only(top: 3),
                              child: Card(
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    side:
                                        BorderSide(color: maincolor, width: 2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20.0, 0.0, 15.0, 13.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                stream.data.docs[index]
                                                            ['isMultiple'] ==
                                                        false
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            32,
                                                                            9,
                                                                            20,
                                                                            10),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      Divider(
                                                                        height:
                                                                            1.0,
                                                                        color:
                                                                            maincolor,
                                                                        indent:
                                                                            0,
                                                                        endIndent:
                                                                            0,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      Text(
                                                                          '1)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  0],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '2)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  1],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '3)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  2],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '4)  ' +
                                                                              stream.data.docs[index][
                                                                                  'answer'],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                    ])),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                              ]),
                                        )
                                      ])));
                        });
                }))
      ]));
    }

    Widget _toefl(BuildContext context) {
      return Container(
          child: Column(children: <Widget>[
        SizedBox(height: 20.0),
        Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: query3.snapshots(),
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
                          return Container(
                              padding: EdgeInsets.only(top: 3),
                              child: Card(
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    side:
                                        BorderSide(color: maincolor, width: 2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20.0, 0.0, 15.0, 13.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                stream.data.docs[index]
                                                            ['isMultiple'] ==
                                                        false
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            32,
                                                                            9,
                                                                            20,
                                                                            10),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      Divider(
                                                                        height:
                                                                            1.0,
                                                                        color:
                                                                            maincolor,
                                                                        indent:
                                                                            0,
                                                                        endIndent:
                                                                            0,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      Text(
                                                                          '1)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  0],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '2)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  1],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '3)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  2],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '4)  ' +
                                                                              stream.data.docs[index][
                                                                                  'answer'],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                    ])),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                              ]),
                                        )
                                      ])));
                        });
                }))
      ]));
    }

    Widget _extra(BuildContext context) {
      return Container(
          child: Column(children: <Widget>[
        SizedBox(height: 20.0),
        Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: query4.snapshots(),
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
                          return Container(
                              padding: EdgeInsets.only(top: 3),
                              child: Card(
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    side:
                                        BorderSide(color: maincolor, width: 2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20.0, 0.0, 15.0, 13.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                stream.data.docs[index]
                                                            ['isMultiple'] ==
                                                        false
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text('Q.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            27,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            maincolor,
                                                                      )),
                                                                  Flexible(
                                                                      child: Padding(
                                                                          padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                          child: Text(stream.data.docs[index]['problemtext'],
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              ))))
                                                                ]),
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            32,
                                                                            9,
                                                                            20,
                                                                            10),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      Divider(
                                                                        height:
                                                                            1.0,
                                                                        color:
                                                                            maincolor,
                                                                        indent:
                                                                            0,
                                                                        endIndent:
                                                                            0,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      Text(
                                                                          '1)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  0],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '2)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  1],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '3)  ' +
                                                                              stream.data.docs[index]['multipleWrongAnswers'][
                                                                                  2],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                          '4)  ' +
                                                                              stream.data.docs[index][
                                                                                  'answer'],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                    ])),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      stream.data
                                                                              .docs[index]
                                                                          [
                                                                          'creator'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                  Text(' 이/가 등록 ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.grey)),
                                                                ]),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 30),
                                                              width: 330,
                                                              child:
                                                                  RaisedButton(
                                                                color:
                                                                    maincolor,
                                                                child: Text(
                                                                  "담기",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(_auth
                                                                          .currentUser
                                                                          .uid)
                                                                      .get()
                                                                      .then((DocumentSnapshot
                                                                          ds) {
                                                                    problemTypes =
                                                                        ds['problemTypes'];
                                                                    print(
                                                                        problemTypes);
                                                                  });
                                                                  _body(
                                                                      context,
                                                                      stream.data
                                                                              .docs[
                                                                          index]);
                                                                },
                                                              ),
                                                            ),
                                                          ])
                                              ]),
                                        )
                                      ])));
                        });
                }))
      ]));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "문제 은행",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: DefaultTabController(
            length: 4,
            child: Column(children: <Widget>[
              Container(
                constraints: BoxConstraints.expand(height: 50),
                child: TabBar(
                  labelColor: Colors.black,
                  indicatorColor: Color.fromRGBO(86, 171, 190, 1.0),
                  tabs: [
                    Tab(
                      text: "토익",
                    ),
                    Tab(text: "생활영어"),
                    Tab(
                      text: "토플",
                    ),
                    Tab(text: "기타"),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                      child: TabBarView(
                children: [
                  SingleChildScrollView(child: _toeic(context)),
                  SingleChildScrollView(child: _lifeEng(context)),
                  SingleChildScrollView(child: _toefl(context)),
                  SingleChildScrollView(child: _extra(context))
                ],
              )))
            ])));
  }
}
