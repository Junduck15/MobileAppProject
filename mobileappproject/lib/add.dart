import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';
import 'dart:async';
import 'added.dart';

class Add extends StatefulWidget {
  _Add createState() => _Add();
}

class _Add extends State<Add> {
  File _image;
  List<dynamic> problemTypes = [];
  String problemType;
  bool isMultiple;
  var imageString;
  String username;
  bool isSwitched = false;
  String problemVal = "";
  String answerVal = "";
  String multi1Val = "";
  String multi2Val = "";
  String multi3Val = "";
  String multiAnswerVal = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AsyncSnapshot snap;
  var _selectedVal = '토익';
  final _formKey = GlobalKey<FormState>();
  final _formKeyMulti = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final problemController = TextEditingController(text: problemVal);
    final answerController = TextEditingController(text: answerVal);
    final multi1Controller = TextEditingController(text: multi1Val);
    final multi2Controller = TextEditingController(text: multi2Val);
    final multi3Controller = TextEditingController(text: multi3Val);
    final multiAnswerController = TextEditingController(text: multiAnswerVal);

    bool isMultiple = false;
    Future<void> _addPathToDatabase(String text) async {
      try {
        final ref = FirebaseStorage.instance.ref().child(text);
        imageString = await ref.getDownloadURL();
      } catch (e) {
        print(e.message);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(e.message),
              );
            });
      }
    }

    Future<void> _uploadImageToFirebase(PickedFile image) async {
      try {
        int randomNumber = Random().nextInt(100000);
        String imageLocation = 'image${randomNumber}.jpg';

        final Reference storageReference =
            FirebaseStorage.instance.ref().child(imageLocation);
        final UploadTask uploadTask =
            storageReference.putFile(File(image.path));
        await uploadTask.whenComplete(() => _addPathToDatabase(imageLocation));
      } catch (e) {
        print(e.message);
      }
    }

    getImage() async {
      var image = await _picker.getImage(source: ImageSource.gallery);
      setState(() {
        _image = File(image.path);
      });
      _uploadImageToFirebase(image);
    }

    Widget isShared = Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(children: [
          Text('다른 사용자들에게 문제 공유'),
          Switch(
              value: isSwitched,
              onChanged: (value) async {
                setState(() {
                  isSwitched = value;
                  problemVal = problemController.text;
                  answerVal = answerController.text;
                  multi1Val = multi1Controller.text;
                  multi2Val = multi2Controller.text;
                  multi3Val = multi3Controller.text;
                  multiAnswerVal = multiAnswerController.text;
                });
              },
              activeTrackColor: Colors.blueAccent,
              activeColor: Colors.blue),
        ]));

    void _showDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final newTypeController = TextEditingController();
          return AlertDialog(
            title: Text("문제 그룹 생성"),
            content: Container(
              height: 80,
              child: Column(
                children: [
                  Text("생성할 문제 그룹 이름을 입력해주세요."),
                  TextField(
                    controller: newTypeController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("생성"),
                onPressed: () {
                  firestore
                      .collection('users')
                      .doc(_auth.currentUser.uid)
                      .update({
                    "problemTypes":
                        FieldValue.arrayUnion([newTypeController.text]),
                  });
                  firestore
                      .collection('users')
                      .doc(_auth.currentUser.uid)
                      .collection('problemType');
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    Widget _ProblemTypeSection(BuildContext context) {
      return Row(
        children: [
          Expanded(
            child: Container(
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
                            problemVal = problemController.text;
                            answerVal = answerController.text;
                            multi1Val = multi1Controller.text;
                            multi2Val = multi2Controller.text;
                            multi3Val = multi3Controller.text;
                            multiAnswerVal = multiAnswerController.text;
                          });
                        },
                        items: problemTypes.map((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? '문제 순서를 선택하지 않았습니다.' : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: RaisedButton(
              color: maincolor,
              child: Text(
                '+',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _showDialog();
              },
            ),
          ),
        ],
      );
    }

    Widget _body(BuildContext context) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(_auth.currentUser.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data.data == null ||
              snapshot.data.data()["problemTypes"] == null) {
            problemTypes = problemTypes = [];
          } else {
            problemTypes = snapshot.data.data()["problemTypes"];
            snap = snapshot;
          }

          return Form(
            // key: _formKey,
            child: Column(
              children: [
                _ProblemTypeSection(context),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      );
    }

    Widget multipleChoice = Container(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
        child: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: multi1Controller,
              decoration: new InputDecoration(
                labelText: "오답1",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: multi2Controller,
              decoration: new InputDecoration(
                labelText: "오답2",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: multi3Controller,
              decoration: new InputDecoration(
                labelText: "오답3",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: multiAnswerController,
              decoration: new InputDecoration(
                labelText: "정답을 입력해주세요.",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          isShared
        ]));

    Widget problemSection = Container(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('문제'),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: problemController,
              decoration: new InputDecoration(
                labelText: "문제를 입력해주세요.",
                fillColor: Colors.black,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: IconButton(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: () async {
                  await getImage();
                }),
          ),
          const Divider(
            color: Colors.black,
            height: 1.0,
          ),
        ]));

    Widget answerSection = Container(
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('정답'),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: answerController,
              decoration: new InputDecoration(
                labelText: "정답을 입력해주세요.",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          isShared
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          //backgroundColor: Colors.white,
          title: Text(
            '문제 입력',
            style: TextStyle(color: Colors.white),
          )),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(height: 50),
              child: TabBar(
                labelColor: Colors.black,
                indicatorColor: Color.fromRGBO(86, 171, 190, 1.0),
                tabs: [
                  Tab(text: "주관식"),
                  Tab(text: "객관식"),
                ],
              ),
            ),
            Expanded(
                child: Container(
              child: TabBarView(
                children: [
                  Container(
                      child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        problemSection,
                        SizedBox(
                          height: 30,
                        ),
                        answerSection,
                        SizedBox(
                          height: 30,
                        ),
                        _body(context),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: RaisedButton(
                            color: maincolor,
                            child: Text(
                              '문제 등록',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              firestore
                                  .collection('users')
                                  .doc(_auth.currentUser.uid)
                                  .collection(problemType)
                                  .add({
                                'problemtext': problemController.text,
                                'answer': answerController.text,
                                'picture': imageString,
                                'creator': _auth.currentUser.uid,
                                'isShared': isSwitched,
                                'createdTime': FieldValue.serverTimestamp(),
                                'isMultiple': false
                              });
                              if (_formKey.currentState.validate() &&
                                  problemController.text != "" &&
                                  answerController.text != "") {
                                Navigator.of(context).pushReplacement(
                                    new MaterialPageRoute(
                                        settings:
                                            const RouteSettings(name: '/added'),
                                        builder: (context) => new Added(
                                            problem: problemController.text,
                                            answer: answerController.text,
                                            isMul: false,
                                            snap: snap,
                                            problemType : problemType)));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
                  Container(
                      child: Form(
                    key: _formKeyMulti,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        problemSection,
                        SizedBox(
                          height: 30,
                        ),
                        multipleChoice,
                        SizedBox(
                          height: 30,
                        ),
                        _body(context),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: RaisedButton(
                            color: Colors.blue,
                            child: Text(
                              '문제 등록',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              List<String> multipleWrongAnswers =
                                  new List<String>();
                              multipleWrongAnswers.add(multi1Controller.text);
                              multipleWrongAnswers.add(multi2Controller.text);
                              multipleWrongAnswers.add(multi3Controller.text);
                              firestore
                                  .collection('users')
                                  .doc(_auth.currentUser.uid)
                                  .collection(_selectedVal)
                                  .add({
                                'problemtext': problemController.text,
                                'answer': multiAnswerController.text,
                                'picture': imageString,
                                'creator': _auth.currentUser.uid,
                                'isShared': isSwitched,
                                'multipleWrongAnswers': multipleWrongAnswers,
                                'createdTime': FieldValue.serverTimestamp(),
                                'isMultiple': true
                              });
                              firestore
                                  .collection('users')
                                  .doc(_auth.currentUser.uid)
                                  .update({
                                "problemTypes":
                                    FieldValue.arrayUnion([_selectedVal]),
                              });
                              if (_formKeyMulti.currentState.validate() &&
                                  problemController.text != "" &&
                                  multi1Controller.text != "" &&
                                  multi2Controller.text != "" &&
                                  multi3Controller.text != "" &&
                                  multiAnswerController.text != "" &&
                                  problemType != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Added(
                                          problem: problemController.text,
                                          answer: multiAnswerController.text,
                                          isMul: true)),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
