import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Problem {
  final String problemID;
  final String answer;
  final String creator;
  final bool isShared;
  final String picture;
  final String problemtext;
  final List<dynamic> multipleWrongAnswers;
  final DocumentReference reference;

  Problem.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map != null),
        assert(map['answer'] != null),
        assert(map['creator'] != null),
        assert(map['isShared'] != null),
        assert(map['problemtext'] != null),
        answer = map['answer'],
        creator = map['creator'],
        isShared = map['isShared'],
        picture = map['picture'],
        problemtext = map['problemtext'],
        multipleWrongAnswers = map['multipleWrongAnswers'],
        problemID = reference.id;

  Problem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "$problemtext:$answer>";
}

class Quiz extends StatefulWidget {
  final String problemType;
  final String difficulty;
  final String order;
  final int quizNumber;

  const Quiz({
    Key key,
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
  }) : super(key: key);

  _Quiz createState() => _Quiz(problemType: problemType, difficulty: difficulty, order: order, quizNumber: quizNumber);
}

class _Quiz extends State<Quiz> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  List<Problem> problemList;
  List<String> answerList = [];
  String problemType;
  String difficulty;
  String order;
  int quizNumber = 0;
  int index = 0;
  bool isShuffle = true;
  final _answerController = TextEditingController();

  _Quiz({
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '퀴즈',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _Body(context),
    );
  }

  Widget _Body(BuildContext context) {
    Query problems;

    switch (order) {
      case "Random" :
        problems = FirebaseFirestore.instance.collection('users').doc(auth.currentUser.uid).collection(problemType);
        break;
      case "Newer" :
        problems = FirebaseFirestore.instance.collection('users').doc(auth.currentUser.uid).collection(problemType).orderBy("createdTime", descending: true).limit(quizNumber);
        break;
      case "Older" :
        problems = FirebaseFirestore.instance.collection('users').doc(auth.currentUser.uid).collection(problemType).orderBy("createdTime", descending: false).limit(quizNumber);
        break;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: problems.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        if (order == "Random" && isShuffle) {
          isShuffle = false;
          problemList = snapshot.data.docs
              .map((DocumentSnapshot document) => Problem.fromSnapshot(document))
              .toList()..shuffle();
          if (problemList.length > quizNumber){
            problemList = problemList.sublist(0, quizNumber);
          }
        }
        else {
          problemList = snapshot.data.docs
              .map((DocumentSnapshot document) => Problem.fromSnapshot(document))
              .toList();
        }

        return Column(
          children: [
            Container(
              height: 10,
              child: Divider(),
            ),
            Container(
              height: 30,
              child: Text(
                (index + 1).toString() + '/' + problemList.length.toString(),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            _Picture(context),
            Expanded(
              child: Container(
                child: Text(
                  problemList[index].problemtext,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            _Answer(context),
            Container(
              height: 10,
              child: Divider(),
            ),
            Container(
              height: 50,
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text('이전'),
                    onPressed: () {
                      if (index > 0) {
                        setState(() {
                          if (index < answerList.length) {
                            answerList[index] = _answerController.text;
                          }
                          else {
                            answerList.add(_answerController.text);
                          }
                          index--;
                          _answerController.text = answerList[index];
                        });
                      }
                      else {
                        final snackBar = SnackBar(
                          content: Text('처음 문제입니다!'),
                          action: SnackBarAction(
                            label: '확인',
                            onPressed: () {
                            },
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('다음'),
                    onPressed: () {
                      if (index < problemList.length - 1) {
                        setState(() {
                          if (index < answerList.length) {
                            answerList[index] = _answerController.text;
                          }
                          else {
                            answerList.add(_answerController.text);
                          }
                          index++;
                          if (index < answerList.length) {
                            _answerController.text = answerList[index];
                          }
                          else {
                            _answerController.text = "";
                          }
                        });
                      }
                      else {
                        final snackBar = SnackBar(
                          content: Text('마지막 문제입니다!'),
                          action: SnackBarAction(
                            label: '확인',
                            onPressed: () {
                            },
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _Picture(BuildContext context) {
    if (problemList[index].picture == null) {
      return Container();
    }
    return Container(
        height: 200,
        child: Image.network(
          problemList[index].picture,
        )
    );
  }

  Widget _Answer(BuildContext context) {
    if (problemList[index].multipleWrongAnswers == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 50,
        child: TextField(
          controller: _answerController,
          decoration: InputDecoration(
            filled: true,
            labelText: "답을 입력해주세요.",
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      );
    }

    problemList[index].multipleWrongAnswers.add(problemList[index].answer);

    problemList[index].multipleWrongAnswers..shuffle();

    final _choice1Controller = TextEditingController(text: problemList[index].multipleWrongAnswers[0]);
    final _choice2Controller = TextEditingController(text: problemList[index].multipleWrongAnswers[1]);
    final _choice3Controller = TextEditingController(text: problemList[index].multipleWrongAnswers[2]);
    final _choice4Controller = TextEditingController(text: problemList[index].multipleWrongAnswers[3]);

    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
        child: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: _choice1Controller,
              enabled: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: _choice2Controller,
              enabled: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: _choice3Controller,
              enabled: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: _choice4Controller,
              enabled: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
        ]));
  }
}
