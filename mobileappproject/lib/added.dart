import 'package:flutter/material.dart';

import 'home.dart';
import 'package:mobileappproject/login.dart';

class Added extends StatelessWidget {
  final String problem;
  final String answer;
  final bool isMul;
  final AsyncSnapshot snap;
  final String problemType;

  const Added(
      {Key key,
      this.problem,
      this.answer,
      this.isMul,
      this.snap,
      this.problemType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget prob = Container(
        margin: EdgeInsets.fromLTRB(15, 10, 0, 15),
        child: Column(children: [
          Center(
            child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffd4d4d4),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.fromLTRB(100, 20, 100, 120),
                margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
                child: Text(problem)),
          ),
          const Divider(
            color: Colors.grey,
            height: 1.0,
          ),
        ]));
    Widget answ = Container(
      margin: EdgeInsets.fromLTRB(15, 10, 0, 15),
      child: Column(
        children: [
          Center(
            child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffd4d4d4),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.fromLTRB(100, 20, 100, 120),
                margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
                child: Text(answer)),
          ),
          const Divider(
            color: Colors.grey,
            height: 1.0,
          ),
        ],
      ),
    );
    Widget buttons = Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(left: 10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.fromLTRB(40, 5, 40, 5),
              color: maincolor,
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/home'),
                );
                //Navigator.pop(context);
              },
            ))
      ],
    ));
    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: maincolor,
          title: Text(
            '등록된 문제 확인',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(15, 10, 0, 15),
                child: Text('등록된 문제')),
            prob,
            Container(
                margin: EdgeInsets.fromLTRB(15, 10, 0, 15), child: Text('정답')),
            answ,
            buttons
          ],
        ),
      ),
    );
  }
}
