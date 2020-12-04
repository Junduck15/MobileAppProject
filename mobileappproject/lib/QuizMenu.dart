import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobileappproject/login.dart';

class QuizMenu extends StatefulWidget {
  _QuizMenu createState() => _QuizMenu();
}

class _QuizMenu extends State<QuizMenu> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<dynamic> problemTypes = [];
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
  String difficulty;
  String order;

  final _quizNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _navigateAndResetInputs(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Quiz(
          problemType: problemType,
          difficulty: difficulty,
          order: order,
          quizNumber: int.parse(_quizNumberController.text),
        ),
      ),
    );

    setState(() {
      problemType = null;
      difficulty = null;
      order = null;
      _quizNumberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Quiz',
          style: TextStyle(color: Colors.white,fontSize: 25),
        ),
      ),
      body: _Body(context),

    );
  }

  Widget _Body(BuildContext context) {
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
        }

        return Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(
                height: 30,
              ),
              _ProblemTypeSection(context),
              SizedBox(
                height: 30,
              ),
              _DifficultySection(context),
              SizedBox(
                height: 30,
              ),
              _OrderSection(context),
              SizedBox(
                height: 30,
              ),
              _QuizNumberSection(context),
              SizedBox(
                height: 30,
              ),
              MyStatefulWidget(),
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
                )
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ProblemTypeSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
                SizedBox(height: 10,),
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
                          value == null ? '문제 그룹을 선택하지 않았습니다.' : null,
                    ),
                  ),
                )
              ]);
        },
      ),
    );
  }

  Widget _DifficultySection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Text(
            '문제 난이도',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10,),
          InputDecorator(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                hint: Text("문제의 난이도를 선택해주세요."),
                value: difficulty,
                isDense: true,
                onChanged: (newValue) {
                  setState(() {
                    difficulty = newValue;
                  });
                },
                items: difficulties.map((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? '출제 문제를 선택하지 않았습니다.' : null,
              ),
            ),
          )
          ]
          );
        },
      ),
    );
  }

  Widget _OrderSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Text(
            '문제 정렬 기준',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10,),
          InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                hint: Text("문제 순서를 선택해주세요."),
                value: order,
                isDense: true,
                onChanged: (newValue) {
                  setState(() {
                    order = newValue;
                  });
                },
                items: orders.map((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? '문제 순서를 선택하지 않았습니다.' : null,
              ),
            ),
          )
          ]
          );
        },
      ),
    );
  }

  Widget _QuizNumberSection(BuildContext context) {
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
      SizedBox(height: 10,),
      TextFormField(
        decoration: InputDecoration(
          labelText: "문제 수를 입력해주세요.",
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        controller: _quizNumberController,
        validator: (value) {
          if (value.isEmpty) {
            return '문제 수를 입력하지 않았습니다.';
          }
          return null;
        },
      )
      ]
      ),
    );
  }

}

String a = 10.toString();
String b = 20.toString();
String c = 30.toString();

enum SingingCharacter { a, b, c }

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  SingingCharacter _character = SingingCharacter.a;

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: const Text('10개'),
            leading: Radio(
              value: SingingCharacter.a,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('20개'),
            leading: Radio(
              value: SingingCharacter.b,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('30개'),
            leading: Radio(
              value: SingingCharacter.c,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}


