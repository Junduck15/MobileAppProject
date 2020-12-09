import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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
  List<String> problemCategories = ["생활영어", "토플", "토익", "기타"];
  File _image;
  List<dynamic> problemTypes = [];
  String problemCategory;
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
  final _formKey = GlobalKey<FormState>();
  final _formKeyMulti = GlobalKey<FormState>();
  String category = "temp";
  var _problemWritten = false;
  var _answerWritten = false;
  File pickedImage;
  String translated = "";
  String translated1 = "";
  bool isImageLoaded = false;

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

    Future<void> _uploadImageToFirebase(File image) async {
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

    // getImage() async {
    //   var image = await _picker.getImage(source: ImageSource.gallery);
    //   setState(() {
    //     _image = File(image.path);
    //   });
    //   _uploadImageToFirebase(image);
    // }

    Widget isShared = Container(
        margin: EdgeInsets.fromLTRB(20, 5, 0, 5),
        child: Row(children: [
          Text(
            '다른 사용자들에게 문제 공유  ',
            style: TextStyle(fontSize: 15.5),
          ),
          Transform.scale(
              scale: 1.3,
              child: Switch(
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
                activeColor: Colors.blue,
              )),
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
                child: Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
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
            ],
          );
        },
      );
    }

    Widget _problemCategory = Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '문제 분류',
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
                      hint: Text("문제 카테고리를 선택해주세요."),
                      value: problemCategory,
                      isDense: true,
                      onChanged: (newValue) {
                        setState(() {
                          problemCategory = newValue;
                          problemVal = problemController.text;
                          answerVal = answerController.text;
                          multi1Val = multi1Controller.text;
                          multi2Val = multi2Controller.text;
                          multi3Val = multi3Controller.text;
                          multiAnswerVal = multiAnswerController.text;
                        });
                      },
                      items: problemCategories.map((dynamic value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? '문제 카테고리를 선택하지 않았습니다.' : null,
                    ),
                  ),
                )
              ]);
        },
      ),
    );

    Widget _ProblemTypeSection(BuildContext context) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        hint: Text("문제 그룹을 선택해주세요."),
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
              width: 80,
              height: 70,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
              child: Column(children: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.add,
                    size: 30,
                  ),
                  onPressed: () {
                    _showDialog();
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '그룹 추가',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                )
              ])),
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
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '정답 입력',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextFormField(
              controller: multi1Controller,
              validator: (value) {
                if (value.isEmpty) {
                  return '문제 등록을 위해 오답을 입력하시오.';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "오답1",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextFormField(
              controller: multi2Controller,
              validator: (value) {
                if (value.isEmpty) {
                  return '문제 등록을 위해 오답을 입력하시오.';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "오답2",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextFormField(
              controller: multi3Controller,
              validator: (value) {
                if (value.isEmpty) {
                  return '문제 등록을 위해 오답을 입력하시오.';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "오답3",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 30),
            child: TextFormField(
              controller: multiAnswerController,
              validator: (value) {
                if (value.isEmpty) {
                  return '문제 등록을 위해 정답을 입력하시오.';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "정답을 입력해주세요.",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
        ]));
        Future readText() async {
      FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
      TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
      VisionText readText = await recognizeText.processImage(ourImage);

      for (TextBlock block in readText.blocks) {
        for (TextLine line in block.lines) {
          translated += line.text;
          print(line.text);
        }
      }
       setState(() {
         translated1=translated;
                          });
      print(translated);
    }
    Future pickImage() async {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("사진 읽어오기"),
                content: Container(
                  
                  child: Column(
                    children: [
                      SizedBox(height: 50.0),
                      isImageLoaded
                          ? Center(
                              child: Container(
                                  height: 200.0,
                                  width: 200.0,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: FileImage(pickedImage),
                                          fit: BoxFit.cover))),
                            )
                          : Container(),
                     
                      FlatButton(
                        child: Text('사진 불러오기'),
                        onPressed: () async {
                          var tempStore = await ImagePicker.pickImage(
                              source: ImageSource.gallery);

                          setState(() {
                            pickedImage = tempStore;
                            isImageLoaded = true;
                          });
                           _uploadImageToFirebase(pickedImage);
                        },
                      ),
                    
                    FlatButton(
                        child: Text('텍스트로 변환하기'),
                        onPressed: () async {
                          translated="";
                         await readText();
                         problemVal = translated;
                         Navigator.pop(context);
                        },
                      ),
                      
                    ],
                  ),
                ));
          });
    }

    

    Widget problemSection = Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '문제 입력',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 3),
            child: TextFormField(
              controller: problemController,
              validator: (value) {
                if (value.isEmpty) {
                  return '문제 등록을 위해 문제를 입력하시오.';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "문제를 입력해주세요.",
                fillColor: Colors.black,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Container(
            //alignment: Alignment.bottomCenter,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //SizedBox(width: 40,),
                  FlatButton(
                      child: Text('사진으로 문제입력'),
                      onPressed: () {
                        pickImage();
                      }),
                  
                ]),
          ),
        ]));

    Widget answerSection = Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정답 입력',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 30),
            child: TextFormField(
              controller: answerController,
              validator: (value) {
                if (value.isEmpty) {
                  return '문제등록을 위해 정답을 입력해주시오.';
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "정답을 입력해주세요.",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          //backgroundColor: Colors.white,
          title: Text(
            '새로운 문제 등록',
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
                  Tab(
                    text: "주관식",
                  ),
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
                        answerSection,
                        _problemCategory,
                        SizedBox(
                          height: 10,
                        ),
                        _body(context),
                        isShared,
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: RaisedButton(
                            color: maincolor,
                            child: Text(
                              '문제 등록',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {

                              DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid)
                                  .collection(problemType).doc();
                              ref.set({
                                'problemtext': problemController.text,
                                'problemtype': problemType,
                                'answer': answerController.text,
                                'picture': imageString,
                                'creator': _auth.currentUser.uid,
                                'isShared': isSwitched,
                                'createdTime': FieldValue.serverTimestamp(),
                                'isMultiple': false,
                                'id' : ref.id,
                              });
                              if (isSwitched) {
                                firestore.collection(problemCategory).add({
                                  'problemtext': problemController.text,
                                  'answer': answerController.text,
                                  'problemtype': problemType,
                                  'picture': imageString,
                                  'creator': _auth.currentUser.uid,
                                  'isShared': isSwitched,
                                  'createdTime': FieldValue.serverTimestamp(),
                                  'isMultiple': false
                                });
                              }
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
                                            problemType: problemType.toString())));
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
                        multipleChoice,
                        _problemCategory,
                        SizedBox(
                          height: 10,
                        ),
                        _body(context),
                        isShared,
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
                                  '문제 등록',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                  ),
                                ),
                                onPressed: () {
                                  List<String> multipleWrongAnswers =
                                      new List<String>();
                                  multipleWrongAnswers
                                      .add(multi1Controller.text);
                                  multipleWrongAnswers
                                      .add(multi2Controller.text);
                                  multipleWrongAnswers
                                      .add(multi3Controller.text);

                                  DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid)
                                      .collection(problemType).doc();
                                  ref.set({
                                    'problemtext': problemController.text,
                                    'answer': multiAnswerController.text,
                                    'picture': imageString,
                                    'creator': _auth.currentUser.uid,
                                    'problemtype': problemType,
                                    'isShared': isSwitched,
                                    'multipleWrongAnswers':
                                        multipleWrongAnswers,
                                    'createdTime': FieldValue.serverTimestamp(),
                                    'isMultiple': true,
                                    'id' : ref.id,
                                  });
                                  if (isSwitched) {
                                    DocumentReference ref2 = FirebaseFirestore.instance.collection(problemCategory).doc();
                                    ref2.set({
                                      'problemtype': problemType,
                                      'problemtext': problemController.text,
                                      'answer': answerController.text,
                                      'picture': imageString,
                                      'creator': _auth.currentUser.uid,
                                      'isShared': isSwitched,
                                      'multipleWrongAnswers':
                                          multipleWrongAnswers,
                                      'createdTime':
                                          FieldValue.serverTimestamp(),
                                      'isMultiple': true,
                                      'id' : ref.id,
                                    });
                                  }
                                  firestore
                                      .collection('users')
                                      .doc(_auth.currentUser.uid)
                                      .update({
                                    "problemTypes":
                                        FieldValue.arrayUnion([problemType]),
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
                                              answer:
                                                  multiAnswerController.text,
                                              isMul: true,
                                              problemType: problemType.toString(),
                                            mul1: multi1Controller.text,
                                            mul2: multi2Controller.text,
                                            mul3: multi3Controller.text,
                                          )),
                                    );
                                  }
                                },
                              )),
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
