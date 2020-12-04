import 'package:flutter/material.dart';
import 'package:mobileappproject/quizResultDetail.dart';
import 'models/problemModel.dart';

class QuizResult extends StatefulWidget {
  final List<Problem> problemList;
  final List<String> answerList;
  final String problemType;
  final String difficulty;
  final String order;
  final int quizNumber;

  const QuizResult({
    Key key,
    this.problemList,
    this.answerList,
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
  }) : super(key: key);

  _QuizResult createState() => _QuizResult(
      problemList: problemList,
      answerList: answerList,
      problemType: problemType,
      difficulty: difficulty,
      order: order,
      quizNumber: quizNumber);
}

class _QuizResult extends State<QuizResult> {

  List<Problem> problemList;
  List<String> answerList;
  String problemType;
  String difficulty;
  String order;
  int quizNumber = 0;

  _QuizResult({
    this.problemList,
    this.answerList,
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
          '퀴즈 결과',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return ListView.builder(
      itemCount: 2 * problemList.length - 1,
      itemBuilder: (BuildContext context, int index) {
        switch (index % 2) {
          case 0:
            return problemTile(((index) / 2).round());
            break;
          case 1:
            return Divider();
            break;
        }
      },
    );
  }

  Widget problemTile(int index) {
    int displayIndex = index + 1;
    bool isWrong = (problemList[index].answer != answerList[index]);
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultDetail(
              problemList: problemList,
              answerList: answerList,
              problemType: problemType,
              difficulty: difficulty,
              order: order,
              quizNumber: quizNumber,
              index: index,
            ),
          ),
        );
      },
      leading: Text("$displayIndex번"),
      title: Text(
         isWrong ? "틀림" : "맞음",
        style: TextStyle(
          color: isWrong ? Colors.red : Colors.blue,
        ),
      ),
      subtitle: Text(
        problemList[index].multipleWrongAnswers == null ? "주관식" : "객관식",
      ),
      trailing: FlatButton(
        child: Text("trailing"),
      ),
    );
  }
}
