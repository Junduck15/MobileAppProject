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
  String problemType;
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Query query = FirebaseFirestore.instance.collection('생활영어');
    Query query2 = FirebaseFirestore.instance.collection('토익');
    Query query3 = FirebaseFirestore.instance.collection('토플');
    Query query4 = FirebaseFirestore.instance.collection('기타');

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
    void _showDialog({pt}) {
      print(pt);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("문제 그룹 지정"),
            content: Container(
              height: 80,
              child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        hint: Text("문제 그룹을 선택해주세요."),
                        value: pt,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            pt = newValue;
                          });
                        },
                        items: problemTypes.map((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? '문제 순서를 선택하지 않았습니다.' : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
              width: 80,
              height: 70,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
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
              )
          ));
        },
      );
    }

    Widget _ProblemTypeSection(BuildContext context) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        hint: Text("문제 그룹을 선택해주세요."),
                        value: problemType,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            problemType = newValue;
                          });
                        },
                        items: problemTypes.map((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? '문제 순서를 선택하지 않았습니다.' : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
              width: 80,
              height: 70,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
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
      );
    }

    Widget _body(BuildContext context) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(_auth.currentUser.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data.data == null ||
              snapshot.data.data()["problemTypes"] == null) {
            problemTypes = [];
          } else {
            problemTypes = snapshot.data.data()["problemTypes"];
          }

          return Form(
            // key: _formKey,
            child: Column(
              children: [
                _ProblemTypeSection(context),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      );
    }




    Widget _lifeEng (BuildContext context) { return Container(
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
                                              20.0, 0.0, 0.0, 15.0),
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
                                                    ? Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                                Container(
                                                  child: FlatButton(
                                                    child: Text("담기"),
                                                    onPressed: () {
                                                      
                                                       firestore
                                      .collection('users')
                                      .doc(_auth.currentUser.uid)
                                      .update({
                                    "problemTypes":
                                        FieldValue.arrayUnion([stream.data.docs[index][
                                                                  'problemtype']]),
                                  });
                                                      stream.data.docs[index][
                                                                  'isMultiple'] ==
                                                              false
                                                          ? firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index][
                                                                  'problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            })
                                                          : firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index]
                                                                  ['problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'multipleWrongAnswers': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'multipleWrongAnswers'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            });
                                                    },
                                                  ),
                                                ),
                                              ]))
                                    ])));
                      });
              }))
    ]));};
    Widget _toeic (BuildContext context){ return Container(
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
                                              20.0, 0.0, 0.0, 15.0),
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
                                                    ? Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                               Container(
                                                  child: FlatButton(
                                                    child: Text("담기"),
                                                    onPressed: () {
                                                   
                                                       firestore
                                      .collection('users')
                                      .doc(_auth.currentUser.uid)
                                      .update({
                                    "problemTypes":
                                        FieldValue.arrayUnion([stream.data.docs[index][
                                                                  'problemtype']]),
                                  });
                                                      stream.data.docs[index][
                                                                  'isMultiple'] ==
                                                              false
                                                          ? firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index][
                                                                  'problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            })
                                                          : firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index]
                                                                  ['problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'multipleWrongAnswers': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'multipleWrongAnswers'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            });
                                                    },
                                                  ),
                                                )
                                              ]))
                                    ])));
                      });
              }))
    ]));}
    Widget _toefl (BuildContext context){return Container(
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
                                              20.0, 0.0, 0.0, 15.0),
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
                                                    ? Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                               Container(
                                                  child: FlatButton(
                                                    child: Text("담기"),
                                                    onPressed: () {
                                                      
                                                       firestore
                                      .collection('users')
                                      .doc(_auth.currentUser.uid)
                                      .update({
                                    "problemTypes":
                                        FieldValue.arrayUnion([stream.data.docs[index][
                                                                  'problemtype']]),
                                  });
                                                      stream.data.docs[index][
                                                                  'isMultiple'] ==
                                                              false
                                                          ? firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index][
                                                                  'problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            })
                                                          : firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index]
                                                                  ['problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'multipleWrongAnswers': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'multipleWrongAnswers'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            });
                                                    },
                                                  ),
                                                
                                                )
                                              ]))
                                    ])));
                      });
              }))
    ]));}
    Widget _extra (BuildContext context) {return Container(
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
                                              20.0, 0.0, 0.0, 15.0),
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
                                                    ? Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                                Container(
                                                  child: FlatButton(
                                                    child: Text("담기"),
                                                    onPressed: () {
                                                      _showDialog(pt:stream.data
                                                                    .docs[index]
                                                                ['problemtype']);
                                                       firestore
                                      .collection('users')
                                      .doc(_auth.currentUser.uid)
                                      .update({
                                    "problemTypes":
                                        FieldValue.arrayUnion([stream.data.docs[index][
                                                                  'problemtype']]),
                                  }); stream.data.docs[index]['isMultiple'] == false
                                                          ? firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index][
                                                                  'problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            })
                                                          : firestore
                                                              .collection(
                                                                  'users')
                                                              .doc(_auth
                                                                  .currentUser
                                                                  .uid)
                                                              .collection(stream
                                                                      .data
                                                                      .docs[index]
                                                                  ['problemtype'])
                                                              .add({
                                                              'problemtext': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'problemtext'],
                                                              'answer': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['answer'],
                                                              'multipleWrongAnswers': stream
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  'multipleWrongAnswers'],
                                                              'picture': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['picture'],
                                                              'creator': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['creator'],
                                                              'isShared': stream
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['isShared'],
                                                              'createdTime':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                              'isMultiple':
                                                                  false
                                                            });
                                                    },
                                                  ),
                                                )
                                              ]))
                                    ])));
                      });
              }))
    ]));}
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "문제 은행",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Container(child: Text("토익")),
            _toeic(context),
           
            Text("생활영어"),
            _lifeEng(context),
            Text("토플"),
            _toefl(context),
            Text("기타"),
            _extra(context)
          ],
        ))));
  }
}