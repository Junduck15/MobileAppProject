import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:mobileappproject/main.dart';
import 'home.dart';
import 'package:mobileappproject/login.dart';

class Added extends StatelessWidget {
  final String problem;
  final String answer;
  final bool isMul;
  final AsyncSnapshot snap;
  final String problemType;
  final String mul1;
  final String mul2;
  final String mul3;

  const Added({
    Key key,
    this.problem,
    this.answer,
    this.isMul,
    this.snap,
    this.problemType,
    this.mul1,
    this.mul2,
    this.mul3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget check =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(30.0, 30.0, 15.0, 20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          isMul == false
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Container(
                        height: 25.0,
                        width: 65,
                        color: Colors.transparent,
                        child: new Container(
                            decoration: new BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: new Center(
                              child: new Text("주관식",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                            )),
                      ),
                      //Text(await trans()),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Q.',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: maincolor,
                                )),
                            Flexible(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                    child: Text(problem,
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: maincolor,
                                        ))))
                          ]),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        height: 1.0,
                        color: maincolor,
                        indent: 40,
                        endIndent: 20,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('A.',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: maincolor,
                                )),
                            Flexible(
                                child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 9, 20, 15),
                              child: Text(answer,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.redAccent,
                                  )),
                            ))
                          ]),
                    ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Container(
                        height: 25.0,
                        width: 65,
                        color: Colors.transparent,
                        child: new Container(
                            decoration: new BoxDecoration(
                              color: Colors.lightGreen,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: new Center(
                              child: new Text("객관식",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Q.',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: maincolor,
                                )),
                            Flexible(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 9, 20, 15),
                                    child: Text(problem,
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: maincolor,
                                        ))))
                          ]),
                      SizedBox(
                        height: 40,
                      ),
                      Divider(
                        height: 1.0,
                        color: Colors.grey,
                        indent: 40,
                        endIndent: 20,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('A.',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: maincolor,
                                )),
                            Flexible(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 9, 20, 15),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('1)    ' + mul1,
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: maincolor,
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('2)   ' + mul2,
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: maincolor,
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('3)   ' + mul3,
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: maincolor,
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('4)   ' + answer,
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: maincolor,
                                              )),
                                          SizedBox(height: 30,),
                                          Text('정답', style: TextStyle(fontSize: 16),),
                                          SizedBox(height: 10,),
                                          Text(' '+answer,
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.redAccent,
                                              )),

                                        ])))
                          ]),
                      SizedBox(
                        height: 20,
                      ),
                    ])
        ]),
      )
    ]);

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
            SizedBox(
              height: 25,
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.collections_bookmark,
                            size: 23, color: maincolor),
                        SizedBox(
                          width: 7,
                        ),
                        Flexible(
                          child: Text(
                            problemType,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ]),
                ]),
            check,
            buttons
          ],
        ),
      ),
    );
  }
}
