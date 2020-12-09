import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:mobileappproject/models/problemModel.dart';
import 'package:mobileappproject/quizResult.dart';
import 'login.dart';

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

  _Quiz createState() => _Quiz(
      problemType: problemType,
      difficulty: difficulty,
      order: order,
      quizNumber: quizNumber);
}

class _Quiz extends State<Quiz> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<Problem> problemList;
  List<String> answerList;
  List<int> indexOfNoAnswer = [];
  String problemType;
  String difficulty;
  String order;
  int quizNumber = 0;
  int index = 0;
  bool isShuffle = true;
  bool isFirst = true;
  final _answerController = TextEditingController();
  String multipleAnswer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _Quiz({
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
  });

  _initAnswerList(int quizNumber) {
    answerList = List.filled(quizNumber, "");
    this.quizNumber = quizNumber;
  }

  _moveProblem(int toIndex) {
    setState(() {
      if (problemList[index].multipleWrongAnswers == null) {
        answerList[index] = _answerController.text;
      } else {
        answerList[index] = multipleAnswer;
      }
      index = toIndex;
      if (problemList[index].multipleWrongAnswers == null) {
        _answerController.text = answerList[index];
      } else {
        multipleAnswer = answerList[index];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text("퀴즈를 종료하시겠습니까?", style: TextStyle(fontSize: 17),),
                  actions: [
                    FlatButton(
                      child: Text("취소", style: TextStyle(fontSize: 16, color: Colors.black38),),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("종료", style: TextStyle(fontSize: 16),),
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName('/home'),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: Text(
          '퀴즈',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: _Body(context),
    );
  }

  Widget _Body(BuildContext context) {
    Query problems;

    switch (order) {
      case "Random":
        problems = FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser.uid)
            .collection(problemType);
        break;
      case "Newer":
        problems = FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser.uid)
            .collection(problemType)
            .orderBy("createdTime", descending: true)
            .limit(quizNumber);
        break;
      case "Older":
        problems = FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser.uid)
            .collection(problemType)
            .orderBy("createdTime", descending: false)
            .limit(quizNumber);
        break;
    }

    if (isFirst) {
      isFirst = false;
      return FutureBuilder<QuerySnapshot>(
        future: problems.get(),
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
                .map((DocumentSnapshot document) =>
                    Problem.fromSnapshot(document))
                .toList()
                  ..shuffle();
            if (problemList.length > quizNumber) {
              problemList = problemList.sublist(0, quizNumber);
            }
          } else if (order != "Random") {
            problemList = snapshot.data.docs
                .map((DocumentSnapshot document) =>
                    Problem.fromSnapshot(document))
                .toList();
          }
          _initAnswerList(snapshot.data.size);
          return _Sections(context);
        },
      );
    }

    return _Sections(context);
  }

  Widget _Sections(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Picture(context),
        Padding(
          padding: EdgeInsets.fromLTRB(35.0, 30.0, 35.0, .0),
          child: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Q.',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: maincolor,
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  SingleChildScrollView(
                      child: Container(
                          height: 180,
                          child: SingleChildScrollView(
                              child: Text(problemList[index].problemtext,
                                  style: TextStyle(
                                    fontSize: 18.5,
                                    color: Colors.black,
                                  )))))
                ]),
          ),
        ),
        _Answer(context),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 40,
            child: Text(
              (index + 1).toString() + '/' + problemList.length.toString(),
              maxLines: 1,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
          ),
        ]),
        Container(
          height: 50,
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Icon(Icons.keyboard_arrow_left, size: 35,color: maincolor,),
                  Text('이전 문제', style: TextStyle(fontSize: 17,color: maincolor,)),
                ]),
                onPressed: () {
                  if (index > 0) {
                    setState(() {
                      _moveProblem(index - 1);
                    });
                  } else {
                    final snackBar = SnackBar(
                      content: Text('처음 문제입니다!'),
                      action: SnackBarAction(
                        label: '확인',
                        onPressed: () {},
                      ),
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  }
                },
              ),
              Container(
                width: 150,
                child: FlatButton(
                  child: Text("채점하기", style: TextStyle(color: Colors.black38)),
                  onPressed: () {
                    if (problemList[index].multipleWrongAnswers == null) {
                      answerList[index] = _answerController.text;
                    } else {
                      answerList[index] = multipleAnswer;
                    }
                    if (answerList.contains("")) {
                      int cur = 0;
                      indexOfNoAnswer = [];
                      while (answerList.indexOf("", cur) != -1) {
                        indexOfNoAnswer.add(answerList.indexOf("", cur) + 1);
                        cur = answerList.indexOf("", cur) + 1;
                      }
                      String alertIndexOfNoAnswer =
                          indexOfNoAnswer.join("번, ") + "번";
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                                "$alertIndexOfNoAnswer 문제를 아직 풀지 않았습니다. 그래도 채점하시겠습니까?"),
                            actions: [
                              FlatButton(
                                child: Text("채점"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizResult(
                                        problemList: problemList,
                                        answerList: answerList,
                                        problemType: problemType,
                                        difficulty: difficulty,
                                        order: order,
                                        quizNumber: quizNumber,
                                        isDailyQuiz: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              FlatButton(
                                child: Text("계속 풀기"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _moveProblem(indexOfNoAnswer[0] - 1);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizResult(
                            problemList: problemList,
                            answerList: answerList,
                            problemType: problemType,
                            difficulty: difficulty,
                            order: order,
                            quizNumber: quizNumber,
                            isDailyQuiz: false,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              FlatButton(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('다음 문제', style: TextStyle(fontSize: 17,color: maincolor,)),
                      Icon(Icons.keyboard_arrow_right, size: 35,color: maincolor,),
                    ]),
                onPressed: () {
                  if (index < problemList.length - 1) {
                    _moveProblem(index + 1);
                  } else {
                    final snackBar = SnackBar(
                      content: Text('마지막 문제입니다!'),
                      action: SnackBarAction(
                        label: '확인',
                        onPressed: () {},
                      ),
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    )));
  }

  Widget _Picture(BuildContext context) {
    if (problemList[index].picture == null) {
      return Container();
    }
    return Container(
        height: 200,
        child: Image.network(
          problemList[index].picture,
        ));
  }

  Widget _Answer(BuildContext context) {
    if (problemList[index].multipleWrongAnswers == null) {
      return Column(children: <Widget>[
        SizedBox(
          height: 26,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          height: 60,
          child: TextField(
            controller: _answerController,
            cursorColor: maincolor,
            autofocus: true,
            decoration: InputDecoration(
              fillColor: Colors.transparent,
              filled: true,
              labelText: "답을 입력해주세요.",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 255,
        ),
      ]);
    }

    if (!problemList[index]
        .multipleWrongAnswers
        .contains(problemList[index].answer)) {
      problemList[index].multipleWrongAnswers.add(problemList[index].answer);
      problemList[index].multipleWrongAnswers..shuffle();
    }

    final _choice1Controller =
        TextEditingController(text: problemList[index].multipleWrongAnswers[0]);
    final _choice2Controller =
        TextEditingController(text: problemList[index].multipleWrongAnswers[1]);
    final _choice3Controller =
        TextEditingController(text: problemList[index].multipleWrongAnswers[2]);
    final _choice4Controller =
        TextEditingController(text: problemList[index].multipleWrongAnswers[3]);

    return Container(
        padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 10.0),
        child: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  multipleAnswer = _choice1Controller.text;
                });
              },
              borderRadius: BorderRadius.circular(20.0),
              child: TextField(
                controller: _choice1Controller,
                enabled: false,
                decoration: InputDecoration(
                  fillColor: maincolor,
                  filled: multipleAnswer ==
                      problemList[index].multipleWrongAnswers[0],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  multipleAnswer = _choice2Controller.text;
                });
              },
              borderRadius: BorderRadius.circular(20.0),
              child: TextField(
                controller: _choice2Controller,
                enabled: false,
                decoration: InputDecoration(
                  fillColor: maincolor,
                  filled: multipleAnswer ==
                      problemList[index].multipleWrongAnswers[1],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  multipleAnswer = _choice3Controller.text;
                });
              },
              borderRadius: BorderRadius.circular(20.0),
              child: TextField(
                controller: _choice3Controller,
                enabled: false,
                decoration: InputDecoration(
                  fillColor: maincolor,
                  filled: multipleAnswer ==
                      problemList[index].multipleWrongAnswers[2],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  multipleAnswer = _choice4Controller.text;
                });
              },
              borderRadius: BorderRadius.circular(20.0),
              child: TextField(
                controller: _choice4Controller,
                enabled: false,
                decoration: InputDecoration(
                  fillColor: maincolor,
                  filled: multipleAnswer ==
                      problemList[index].multipleWrongAnswers[3],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ),
        ]));
  }
}
