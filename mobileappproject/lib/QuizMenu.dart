import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  int quizNumber;

  final _quizNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
          problemTypes = snapshot.data.data()["problemTypes"];
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    '퀴즈 시작',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Quiz(
                            problemType: problemType,
                            difficulty: difficulty,
                            order: order,
                            quizNumber: quizNumber),
                        ),
                      );
                    }
                  },
                ),
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
          return InputDecorator(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                hint: Text("문제 그룹 선택해주세요."),
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
                validator: (value) => value == null ? '문제 순서를 선택하지 않았습니다.' : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _DifficultySection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                hint: Text("출제 문제를 선택해주세요."),
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
                validator: (value) => value == null ? '문제 순서를 선택하지 않았습니다.' : null,
              ),
            ),
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
          return InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
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
                validator: (value) => value == null ? '문제 순서를 선택하지 않았습니다.' : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _QuizNumberSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        decoration: new InputDecoration(
          labelText: "문제 수를 입력해주세요.",
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        controller: _quizNumberController,
        validator: (value) {
          if (value.isEmpty) {
            return '문제 수를 입력하지 않았습니다.';
          }
          return null;
        },
      ),
    );
  }
}
