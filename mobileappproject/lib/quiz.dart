import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Problem {
  final String problemID;
  final String answer;
  final String creator;
  final bool isShared;
  final String picture;
  final String problemtext;
  final DocumentReference reference;

  Problem.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map != null),
        assert(map['answer'] != null),
        assert(map['creator'] != null),
        assert(map['isShared'] != null),
        assert(map['problemtext'] != null),
        answer = map['answer'],
        creator = map['creator'],
        isShared = map['isShared'],
        picture = map['picture'],
        problemtext = map['problemtext'],
        problemID = reference.id;

  Problem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "$problemtext:$answer>";
}

class Quiz extends StatefulWidget {
  _Quiz createState() => _Quiz();
}

class _Quiz extends State<Quiz> {
  List<Problem> problemList;
  List<String> answerList = [];
  int index = 0;
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '퀴즈',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _Body(context),
    );
  }

  Widget _Body(BuildContext context) {
    CollectionReference problems =
        FirebaseFirestore.instance.collection('problem');

    return StreamBuilder<QuerySnapshot>(
      stream: problems.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        problemList = snapshot.data.docs
            .map((DocumentSnapshot document) => Problem.fromSnapshot(document))
            .toList();

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
            Container(
              height: 50,
              child: TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  filled: true,
                  labelText: '답',
                ),
              ),
            ),
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
                          if (index < answerList.length) {
                            answerList[index] = _answerController.text;
                          }
                          else {
                            answerList.add(_answerController.text);
                          }
                          index--;
                          _answerController.text = answerList[index];
                        });
                      }
                      else {
                        final snackBar = SnackBar(
                          content: Text('처음 문제입니다!'),
                          action: SnackBarAction(
                            label: '확인',
                            onPressed: () {
                            },
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('다음'),
                    onPressed: () {
                      if (index < problemList.length - 1) {
                        setState(() {
                          if (index < answerList.length) {
                            answerList[index] = _answerController.text;
                          }
                          else {
                            answerList.add(_answerController.text);
                          }
                          index++;
                          if (index < answerList.length) {
                            _answerController.text = answerList[index];
                          }
                          else {
                            _answerController.text = "";
                          }
                        });
                      }
                      else {
                        final snackBar = SnackBar(
                          content: Text('마지막 문제입니다!'),
                          action: SnackBarAction(
                            label: '확인',
                            onPressed: () {
                            },
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
        )
    );
  }
}
