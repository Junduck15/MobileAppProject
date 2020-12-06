import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileappproject/login.dart';

class QuizRecordTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => QuizRecordTabState();
}

class QuizRecordTabState extends State<QuizRecordTab> {
  final Color barBackgroundColor = Color(0xff72d8bf);
  final Duration animDuration = Duration(milliseconds: 250);
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<double> dailyQuizRecord = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ];
  List<dynamic> yyyyMMdd = [];
  List<dynamic> Md = [];
  List<dynamic> EEEE = [];
  int touchedIndex;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      yyyyMMdd.add(DateFormat("yyyyMMdd")
          .format(DateTime(now.year, now.month, now.day - i)));
      Md.add(
          DateFormat.Md().format(DateTime(now.year, now.month, now.day - i)));
      EEEE.add(
          DateFormat.EEEE().format(DateTime(now.year, now.month, now.day - i)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser.uid)
          .collection('dailyQuiz')
          .where('date',
              isGreaterThan: DateFormat.Md().format(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day - 7)))
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.active) {
          for (var i = 0; i < snapshot.data.docs.length; i++) {
            Map<String, dynamic> data = snapshot.data.docs[i].data();
            for (var j = 0; j <= 6; j++) {
              if (data['date'] == Md[j]) {
                dailyQuizRecord[j] = data['score'].toDouble();
                break;
              }
            }
          }
        }

        return Container(
            margin: EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            '데일리 퀴즈 점수',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 15,),
                            Text(
                              '지난 일주일',
                              style: TextStyle(
                                  color: maincolor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                          SizedBox(
                            height: 25,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 7.0),
                              child: BarChart(
                                mainBarData(),
                                swapAnimationDuration: animDuration,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.lightGreenAccent,
    double width = 23,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y / 5 + 1 : y / 5,
          colors: isTouched ? [Colors.limeAccent] : [barColor],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, dailyQuizRecord[0],
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, dailyQuizRecord[1],
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, dailyQuizRecord[2],
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, dailyQuizRecord[3],
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, dailyQuizRecord[4],
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, dailyQuizRecord[5],
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, dailyQuizRecord[6],
                isTouched: i == touchedIndex);
          default:
            return null;
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              final now = DateTime.now();
              switch (group.x.toInt()) {
                case 0:
                  weekDay = DateFormat.EEEE()
                      .format(DateTime(now.year, now.month, now.day - 6));
                  break;
                case 1:
                  weekDay = DateFormat.EEEE()
                      .format(DateTime(now.year, now.month, now.day - 5));
                  break;
                case 2:
                  weekDay = DateFormat.EEEE()
                      .format(DateTime(now.year, now.month, now.day - 4));
                  break;
                case 3:
                  weekDay = DateFormat.EEEE()
                      .format(DateTime(now.year, now.month, now.day - 3));
                  break;
                case 4:
                  weekDay = DateFormat.EEEE()
                      .format(DateTime(now.year, now.month, now.day - 2));
                  break;
                case 5:
                  weekDay = DateFormat.EEEE()
                      .format(DateTime(now.year, now.month, now.day - 1));
                  break;
                case 6:
                  weekDay = DateFormat.EEEE().format(now);
                  break;
              }
              return BarTooltipItem(
                  weekDay + '\n' + ((rod.y - 1) * 5).round().toString() + '점',
                  TextStyle(color: Colors.yellow));
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! FlPanEnd &&
                barTouchResponse.touchInput is! FlLongPressEnd) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 15),
          margin: 10,
          getTitles: (double value) {
            final now = DateTime.now();
            switch (value.toInt()) {
              case 0:
                return DateFormat.Md()
                    .format(DateTime(now.year, now.month, now.day - 6));
              case 1:
                return DateFormat.Md()
                    .format(DateTime(now.year, now.month, now.day - 5));
              case 2:
                return DateFormat.Md()
                    .format(DateTime(now.year, now.month, now.day - 4));
              case 3:
                return DateFormat.Md()
                    .format(DateTime(now.year, now.month, now.day - 3));
              case 4:
                return DateFormat.Md()
                    .format(DateTime(now.year, now.month, now.day - 2));
              case 5:
                return DateFormat.Md()
                    .format(DateTime(now.year, now.month, now.day - 1));
              case 6:
                return DateFormat.Md().format(DateTime.now());
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(animDuration + Duration(milliseconds: 50));
  }
}
