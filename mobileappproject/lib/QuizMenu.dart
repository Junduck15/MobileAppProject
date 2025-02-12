import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileappproject/quizRecordTab.dart';
import 'dart:async';
import 'dailyQuiz.dart';
import 'dailyQuiz.dart';
import 'quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';
import 'package:intl/intl.dart';

class QuizMenu extends StatefulWidget {
  _QuizMenu createState() => _QuizMenu();
}

class _QuizMenu extends State<QuizMenu> with TickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<dynamic> problemTypes = [];
  List<dynamic> problemTypesWithProblems = [];
  List<int> problemNumberOfTypes = [];
  List<String> difficulties = [
    "All",
    "Confusing",
    "Understand",
  ];
  List<String> orders = [
    "Random",
    "Newer",
    "Older",
  ];
  String problemType;
  String difficulty = "All";
  String order = "Random";
  double quizNumber = 30;

  final _formKey = GlobalKey<FormState>();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _navigateAndResetInputs(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Quiz(
          problemType: problemType,
          difficulty: difficulty,
          order: order,
          quizNumber: quizNumber.round(),
        ),
      ),
    );

    setState(() {
      problemType = null;
      difficulty = "All";
      order = "Random";
      quizNumber = 30;
    });
  }

  _navigateAndMoveTab(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyQuiz(
          problemTypes: problemTypesWithProblems,
        ),
      ),
    );

    setState(() {
      _tabController.index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        bottom: TabBar(
          indicatorColor: Colors.black38,
          controller: _tabController,
          tabs: [
            Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
              Icon(
                Icons.edit,
                color: Colors.white,
              ),
                  SizedBox(width: 10,),
                  Text('퀴즈 생성',style: TextStyle(color: Colors.white, fontSize: 17),)
            ])),
            Tab(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.description,
                        color: Colors.white,
                      ),
                      SizedBox(width: 9,),
                      Text('DailyQuiz 결과',style: TextStyle(color: Colors.white, fontSize: 17),)
                    ])
            ),
          ],
        ),
        title: Text(
          'Quiz',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _makingQuizTab(context),
          QuizRecordTab(),
        ],
      ),
      floatingActionButton: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(auth.currentUser.uid)
            .collection("dailyQuiz")
            .where('date', isEqualTo: DateFormat('yyyyMMdd').format(DateTime.now()))
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("");
          }

          if (snapshot.data.size > 0) {
            return Visibility(
              visible: false,
              child: FloatingActionButton(
                onPressed: () {
                  _navigateAndMoveTab(context);
                },
                child: Text("Daily"),
                backgroundColor: Colors.orangeAccent,
              ),
            );
          }
          return Visibility(
            visible: _tabController.index == 0,
            child: FloatingActionButton(
              onPressed: () {
                _navigateAndMoveTab(context);
              },
              child: Text("Daily\nQuiz", textAlign: TextAlign.center,style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),),
              backgroundColor: Colors.deepOrangeAccent,
            ),
          );
        },
      ),
    );
  }

  Widget _makingQuizTab(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser.uid)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          snapshot.data.data()["problemTypes"] != null
              ? problemTypes = snapshot.data.data()["problemTypes"]
              : problemTypes = [];
          checkProblemCount();
        }

        return Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(
                height: 30,
              ),
              _problemTypeSection(context),
              SizedBox(
                height: 30,
              ),
              _difficultySection(context),
              SizedBox(
                height: 30,
              ),
              _orderSection(context),
              SizedBox(
                height: 30,
              ),
              _quizNumberSection(context),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  child: RaisedButton(
                    color: maincolor,
                    child: Text(
                      '퀴즈 시작',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _navigateAndResetInputs(context);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _problemTypeSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '문제 그룹',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InputDecorator(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
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
                        value == null ? '문제 그룹을 선택하지 않았습니다.' : (problemNumberOfTypes[problemTypes.indexOf(value)] == 0 ? '해당 그룹에 문제가 존재하지 않습니다.' : null),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _difficultySection(BuildContext context) {
    return Container(
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  '문제 이해도',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 400,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 3),
                        title: Text(
                          '전체',
                          maxLines: 1,
                          softWrap: false,
                        ),
                        leading: Radio(
                          value: difficulties[0],
                          groupValue: difficulty,
                          onChanged: (value) {
                            setState(() {
                              difficulty = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '부족',
                          maxLines: 1,
                          softWrap: false,
                        ),
                        leading: Radio(
                          value: difficulties[1],
                          groupValue: difficulty,
                          onChanged: (value) {
                            setState(() {
                              difficulty = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '완벽',
                          maxLines: 1,
                          softWrap: false,
                        ),
                        leading: Radio(
                          value: difficulties[2],
                          groupValue: difficulty,
                          onChanged: (value) {
                            setState(() {
                              difficulty = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _orderSection(BuildContext context) {
    return Container(
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  '문제 정렬 기준',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 400,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '랜덤',
                          maxLines: 1,
                          softWrap: false,
                        ),
                        leading: Radio(
                          value: orders[0],
                          groupValue: order,
                          onChanged: (value) {
                            setState(() {
                              order = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '최신순',
                          maxLines: 1,
                          softWrap: false,
                        ),
                        leading: Radio(
                          value: orders[1],
                          groupValue: order,
                          onChanged: (value) {
                            setState(() {
                              order = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '오래된순',
                          maxLines: 1,
                          softWrap: false,
                        ),
                        leading: Radio(
                          value: orders[2],
                          groupValue: order,
                          onChanged: (value) {
                            setState(() {
                              order = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _quizNumberSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '총 문제 수',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Slider(
            value: quizNumber,
            min: 10,
            max: 50,
            divisions: 4,
            label: quizNumber.round().toString(),
            onChanged: (value) {
              setState(() {
                quizNumber = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void checkProblemCount() {
    for(var i = 0; i < problemTypes.length; i++){
      FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser.uid)
          .collection(problemTypes[i])
          .snapshots()
          .listen((data) async {
        problemNumberOfTypes.add(data.docs.length);
        if(data.docs.length > 0){
          problemTypesWithProblems.add(problemTypes[i]);
        }
      });
    }
  }
}
