import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/models/problemModel.dart';
import 'package:mobileappproject/quizResult.dart';

class DailyQuiz extends StatefulWidget {

  const DailyQuiz({
    Key key,
  }) : super(key: key);

  _DailyQuiz createState() => _DailyQuiz();
}

class _DailyQuiz extends State<DailyQuiz> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<Problem> problemList;
  List<String> answerList;
  List<int> indexOfNoAnswer = [];
  String difficulty = "All";
  int quizNumber = 10;
  int index = 0;
  bool isShuffle = true;
  bool isFirst = true;
  final _answerController = TextEditingController();
  String multipleAnswer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                  content: Text("퀴즈를 종료하시겠습니까?\n(종료하면 데일리 퀴즈는 0점으로 기록됩니다.)"),
                  actions: [
                    FlatButton(
                      child: Text("종료"),
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName('/home'),
                        );
                      },
                    ),
                    FlatButton(
                      child: Text("계속 풀기"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: Text(
          '데일리 퀴즈',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _Body(context),
    );
  }

  Widget _Body(BuildContext context) {
    Query problems = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .collection("토익");

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

          if (isShuffle) {
            isShuffle = false;
            problemList = snapshot.data.docs
                .map((DocumentSnapshot document) =>
                Problem.fromSnapshot(document))
                .toList()
              ..shuffle();
            if (problemList.length > quizNumber) {
              problemList = problemList.sublist(0, quizNumber);
            }
          } else {
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
                      _moveProblem(index-1);
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
              FlatButton(
                child: Text("채점하기"),
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
                    String alertIndexOfNoAnswer = indexOfNoAnswer.join("번, ") + "번";
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text("$alertIndexOfNoAnswer 문제를 아직 풀지 않았습니다. 그래도 채점하시겠습니까?"),
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
                                      problemType: "",
                                      difficulty: difficulty,
                                      order: "",
                                      quizNumber: quizNumber,
                                      isDailyQuiz: true,
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
                  }
                  else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizResult(
                          problemList: problemList,
                          answerList: answerList,
                          problemType: "",
                          difficulty: difficulty,
                          order: "",
                          quizNumber: quizNumber,
                          isDailyQuiz: true,
                        ),
                      ),
                    );
                  }
                },
              ),
              FlatButton(
                child: Text('다음'),
                onPressed: () {
                  if (index < problemList.length - 1) {
                    _moveProblem(index+1);
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
        ));
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(),
            ),
          ),
        ),
      );
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
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
        child: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                  fillColor: Colors.blue,
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
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                  fillColor: Colors.blue,
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
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                  fillColor: Colors.blue,
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
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                  fillColor: Colors.blue,
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
