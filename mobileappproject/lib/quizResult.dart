import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobileappproject/quizResultDetail.dart';
import 'models/indicator.dart';
import 'models/problemModel.dart';
import 'package:intl/intl.dart';
import 'login.dart' ;

class QuizResult extends StatefulWidget {
  final List<Problem> problemList;
  final List<String> answerList;
  final String problemType;
  final String difficulty;
  final String order;
  final int quizNumber;
  final bool isDailyQuiz;

  const QuizResult({
    Key key,
    this.problemList,
    this.answerList,
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
    this.isDailyQuiz,
  }) : super(key: key);

  _QuizResult createState() => _QuizResult(
      problemList: problemList,
      answerList: answerList,
      problemType: problemType,
      difficulty: difficulty,
      order: order,
      quizNumber: quizNumber,
      isDailyQuiz: isDailyQuiz,
  );
}

class _QuizResult extends State<QuizResult> {

  List<Problem> problemList;
  List<String> answerList;
  List<bool> scoringList;
  String problemType;
  String difficulty;
  String order;
  int quizNumber = 0;
  int wrongNumber = 0;
  int rightNumber = 0;
  int touchedIndex;
  bool isDailyQuiz;
  final FirebaseAuth auth = FirebaseAuth.instance;

  _QuizResult({
    this.problemList,
    this.answerList,
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
    this.isDailyQuiz,
  });

  _scoring() {
    scoringList = [];
    wrongNumber = 0;
    rightNumber = 0;
    for (var index = 0; index < problemList.length; index++) {
      bool isWrong = (problemList[index].answer != answerList[index]);
      isWrong ? wrongNumber++ : rightNumber++;
      scoringList.add(isWrong);
    }
    if (isDailyQuiz == true) {
      Future<void> addDailyQuizRecord() {
        CollectionReference dailyQuiz = FirebaseFirestore.instance.collection('users').doc(auth.currentUser.uid).collection('dailyQuiz');
        return dailyQuiz
            .add({
          'score': (rightNumber / quizNumber) * 100,
          'date': DateFormat('yyyyMMdd').format(DateTime.now()),
        })
            .then((value) => print("Daily Quiz Record Added"))
            .catchError((error) => print("Failed to add Daily Quiz Record: $error"));
      }
      addDailyQuizRecord();
    }
  }

  @override
  void initState() {
    super.initState();
    _scoring();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolor,
        elevation: 0,
        title: Text(
          '퀴즈 결과',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
      AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse.touchedSectionIndex;
                          }
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: circularChartSections(),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Indicator(
                  color: Colors.indigoAccent,
                  size: 18,
                  text: '   맞음',
                  isSquare: true,
                ),
                SizedBox(
                  height: 10,
                ),
                Indicator(
                  color: Colors.deepOrangeAccent,
                  size: 18,
                  text: '   틀림',
                  isSquare: true,
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    ),
        Expanded(
            child: ListView.builder(
              shrinkWrap: true,
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
            ),
        ),
      ],
    );
  }

  List<PieChartSectionData> circularChartSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 22 : 16;
      final double radius = isTouched ? 70 : 60;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.deepOrangeAccent,
            value: (wrongNumber / quizNumber) * 100,
            title: wrongNumber == 0? '' : '$wrongNumber문제',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.indigoAccent,
            value: (rightNumber / quizNumber) * 100,
            title: rightNumber == 0? '' : '$rightNumber문제',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
          );
        default:
          return null;
      }
    });
  }

  Widget problemTile(int index) {
    int displayIndex = index + 1;
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
      leading: Text("  $displayIndex번", style: TextStyle(fontSize: 18),),
      title: Text(
        scoringList[index] ? "틀림" : "맞음",
        style: TextStyle(fontSize: 18,
          color: scoringList[index] ? Colors.deepOrangeAccent : Colors.indigoAccent,
        ),
      ),
      subtitle: Text(
        problemList[index].multipleWrongAnswers == null ? "주관식" : "객관식",
      ),
      trailing: Icon(Icons.chevron_right, size: 30,),
    );
  }
}