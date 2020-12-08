import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';
import 'package:mobileappproject/main.dart';
import 'package:translator/translator.dart';

import 'add.dart';

class Edit_ProblemPage extends StatefulWidget {
  final String foldername;
  final String problemid;
  final String problem;
  final String answer;
  final bool isMulti;
  final String mul1;
  final String mul2;
  final String mul3;

  Edit_ProblemPage(
      {Key key,
      @required this.foldername,
      this.problemid,
      this.problem,
      this.answer,
      this.isMulti,
      this.mul1,
      this.mul2,
      this.mul3})
      : super(key: key);

  @override
  _Edit_ProblemPageState createState() => _Edit_ProblemPageState();
}

class _Edit_ProblemPageState extends State<Edit_ProblemPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _updateProblemController;
  TextEditingController _updateAnswerController;
  TextEditingController _updateMultiWrong1Controller;
  TextEditingController _updateMultiWrong2Controller;
  TextEditingController _updateMultiWrong3Controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '문제 수정',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Builder(
              builder: (context) {
                return FlatButton(
                  child: Text(
                    '확인',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    if (widget.isMulti == false) {
                      updateproblem_short(
                        _updateProblemController.text,
                        _updateAnswerController.text,
                      );
                    }else{
                      updateproblem_multiple(
                        _updateProblemController.text,
                        _updateAnswerController.text,
                        _updateMultiWrong1Controller.text,
                        _updateMultiWrong2Controller.text,
                        _updateMultiWrong3Controller.text,
                      );
                    }

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(30.0, 30.0, 15.0, 20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 20,
              ),
              widget.isMulti == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          //Text(await trans()),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Q.',
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: maincolor,
                                    )),
                                Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 12),
                                    width: 320,
                                    child: TextField(
                                      autofocus: true,
                                      controller: _updateProblemController,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                          SizedBox(
                            height: 60,
                          ),
                          Divider(
                            height: 1.0,
                            color: maincolor,
                            indent: 40,
                            endIndent: 20,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('A.',
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: maincolor,
                                    )),
                                Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 12),
                                    width: 320,
                                    child: TextField(
                                      controller: _updateAnswerController,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.redAccent),
                                        ),
                                        labelText: '정답',
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                        ])
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Q.',
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: maincolor,
                                    )),
                                Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 12),
                                    width: 320,
                                    child: TextField(
                                      autofocus: true,
                                      controller: _updateProblemController,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                          SizedBox(
                            height: 60,
                          ),
                          Divider(
                            height: 1.0,
                            color: maincolor,
                            indent: 40,
                            endIndent: 20,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('A.',
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: maincolor,
                                    )),
                                Flexible(
                                    child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(12, 9, 20, 15),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                //margin: EdgeInsets.only(left :12),
                                                width: 320,
                                                child: TextField(
                                                  controller:
                                                      _updateMultiWrong1Controller,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    labelText: '오답1',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                //margin: EdgeInsets.only(left :12),
                                                width: 320,
                                                child: TextField(
                                                  controller:
                                                      _updateMultiWrong2Controller,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    labelText: '오답2',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                //margin: EdgeInsets.only(left :12),
                                                width: 320,
                                                child: TextField(
                                                  controller:
                                                      _updateMultiWrong3Controller,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    labelText: '오답3',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Container(
                                                //margin: EdgeInsets.only(left :12),
                                                width: 320,
                                                child: TextField(
                                                  controller:
                                                      _updateAnswerController,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.redAccent),
                                                    ),
                                                    labelText: '정답',
                                                  ),
                                                ),
                                              ),
                                            ])))
                              ]),
                          SizedBox(
                            height: 20,
                          ),
                        ])
            ]),
          )
        ]));
  }

  @override
  void initState() {
    super.initState();
    _updateProblemController = TextEditingController(text: widget.problem);
    _updateMultiWrong1Controller = TextEditingController(text: widget.mul1);
    _updateMultiWrong2Controller = TextEditingController(text: widget.mul2);
    _updateMultiWrong3Controller = TextEditingController(text: widget.mul3);
    _updateAnswerController = TextEditingController(text: widget.answer);

    //_updateDescriptionController =
    //TextEditingController(text: widget.description);
  }

//@override
//void dispose() {
//  _updateProblemController.dispose();
//  super.dispose();
//}

  Future<void> updateproblem_short(String problem, String answer) async {
    FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid).collection(widget.foldername).doc(widget.problemid)
        .update({
      'problemtext': problem,
      'answer': answer,
    }).then((value) => print("Problem Updated"))
        .catchError((error) => print("Failed to problem : $error"));

  }

  Future<void> updateproblem_multiple(String problem, String answer, String mul1, String mul2, String mul3) async {
    FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid).collection(widget.foldername).doc(widget.problemid)
        .update({
      'problemtext': problem,
      'answer': answer,
      //'multipleWrongAnswers'[0] : mul1,
      //'multipleWrongAnswers'[1] : mul2,
      //'multipleWrongAnswers'[2] : mul3,
    }).then((value) => print("Problem Updated"))
        .catchError((error) => print("Failed to problem : $error"));

    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection(widget.foldername)
        .doc(widget.problemid)
        .update({
      "multipleWrongAnswers": FieldValue.arrayRemove([widget.mul1, widget.mul2, widget.mul3])
    }).catchError((error) {
      print(error);
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection(widget.foldername)
        .doc(widget.problemid)
        .update({
      "multipleWrongAnswers": FieldValue.arrayUnion(
        [mul1, mul2, mul3,]
      )
    }).catchError((error) {
      print(error);
    });

  }

}
