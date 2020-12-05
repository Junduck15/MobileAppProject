import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobileappproject/quizResultDetail.dart';
import 'models/indicator.dart';
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
  List<bool> scoringList;
  String problemType;
  String difficulty;
  String order;
  int quizNumber = 0;
  int wrongNumber = 0;
  int rightNumber = 0;
  int touchedIndex;

  _QuizResult({
    this.problemList,
    this.answerList,
    this.problemType,
    this.difficulty,
    this.order,
    this.quizNumber,
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
  }

  @override
  Widget build(BuildContext context) {
    _scoring();
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
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
      AspectRatio(
      aspectRatio: 1.3,
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
                  color: Colors.blue,
                  text: '맞음',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.red,
                  text: '틀림',
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
            color: Colors.red,
            value: (wrongNumber / quizNumber) * 100,
            title: '$wrongNumber문제',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: (rightNumber / quizNumber) * 100,
            title: '$rightNumber문제',
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
      leading: Text("$displayIndex번"),
      title: Text(
        scoringList[index] ? "틀림" : "맞음",
        style: TextStyle(
          color: scoringList[index] ? Colors.red : Colors.blue,
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