import 'package:flutter/material.dart';
import 'package:mobileappproject/models/problemModel.dart';

class QuizResultDetail extends StatefulWidget {
  final List<Problem> problemList;
  final List<String> answerList;
  final String problemType;
  final String difficulty;
  final String order;
  final int quizNumber;
  final int index;

  const QuizResultDetail({
    Key key,
    this.problemList,
    this.answerList,
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
    this.index,
  }) : super(key: key);

  _QuizResultDetail createState() => _QuizResultDetail(
        problemList: problemList,
        answerList: answerList,
        problemType: problemType,
        difficulty: difficulty,
        order: order,
        quizNumber: quizNumber,
        index: index,
      );
}

class _QuizResultDetail extends State<QuizResultDetail> {
  List<Problem> problemList;
  List<String> answerList;
  String problemType;
  String difficulty;
  String order;
  String multipleAnswer;
  int quizNumber = 0;
  int index;
  bool isWrong;
  final _answerController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _QuizResultDetail({
    this.problemList,
    this.answerList,
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
    this.index,
  });


  _moveProblem(int toIndex) {
    setState(() {
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
    _moveProblem(index);
    isWrong = (answerList[index] != problemList[index].answer);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isWrong ? "틀린 문제" : "맞은 문제",
          style: TextStyle(color: isWrong ? Colors.red : Colors.indigo),
        ),
      ),
      body: _Body(context),
    );
  }

  Widget _Body(BuildContext context) {
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
              FlatButton(
                child: Text('다음'),
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
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
        height: 190,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                isWrong ? problemList[index].answer : "",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: TextField(
                controller: _answerController,
                enabled: false,
                decoration: InputDecoration(
                  fillColor: isWrong ? Colors.red : Colors.blue,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
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
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: _choice1Controller,
              enabled: false,
              decoration: InputDecoration(
                fillColor: problemList[index].answer == problemList[index].multipleWrongAnswers[0] ? Colors.blue : Colors.red,
                filled: multipleAnswer ==
                    problemList[index].multipleWrongAnswers[0] || problemList[index].answer ==
                    problemList[index].multipleWrongAnswers[0],
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
                fillColor: problemList[index].answer == problemList[index].multipleWrongAnswers[1] ? Colors.blue : Colors.red,
                filled: multipleAnswer ==
                    problemList[index].multipleWrongAnswers[1] || problemList[index].answer ==
                    problemList[index].multipleWrongAnswers[1],
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
                fillColor: problemList[index].answer == problemList[index].multipleWrongAnswers[2] ? Colors.blue : Colors.red,
                filled: multipleAnswer ==
                    problemList[index].multipleWrongAnswers[2] || problemList[index].answer ==
                    problemList[index].multipleWrongAnswers[2],
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
                fillColor: problemList[index].answer == problemList[index].multipleWrongAnswers[3] ? Colors.blue : Colors.red,
                filled: multipleAnswer ==
                    problemList[index].multipleWrongAnswers[3] || problemList[index].answer ==
                    problemList[index].multipleWrongAnswers[3],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
