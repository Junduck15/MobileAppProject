import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'added.dart';

class Add extends StatefulWidget {
  _Add createState() => _Add();
}

class _Add extends State<Add> {
  File _image;
  //String id;
  var imageString;
  String username;
  //_Add({this.id});
  bool isSwitched = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final problem = TextEditingController();
    final answer = TextEditingController();
    final multi1 = TextEditingController();
    final multi2 = TextEditingController();
    final multi3 = TextEditingController();
    final multiAnswer = TextEditingController();
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
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
              activeTrackColor: Colors.blueAccent,
              activeColor: Colors.blue),
        ]));
    Widget multipleChoice = Container(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
        child: Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: multi1,
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
              controller: multi2,
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
              controller: multi3,
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
              controller: multiAnswer,
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
              controller: problem,
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
        ]
        )
        );
    Widget answerSection = Container(
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('정답'),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              controller: answer,
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
    
    Widget submitButton = Center(
        child: RaisedButton(
      padding: EdgeInsets.fromLTRB(80, 5, 80, 5),
      color: Colors.blue,
      child: Text(
        '문제 등록',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        firestore.collection('problem').add({
          'problemtext': problem.text,
          'answer': answer.text,
          'picture': imageString,
          'creator': _auth.currentUser.uid,
          'isShared': isSwitched
        });
        print(_auth.currentUser.uid);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Added(problem: problem.text, answer: answer.text)),
        );
      },
    ));

    return MaterialApp(
      title: 'Flutter layout demo',
      home: DefaultTabController(
       
        length: 2,
        child:
      Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            '문제 입력',
            style: TextStyle(color: Colors.black),
          ),
           bottom: TabBar(
             labelColor: Colors.black,
              tabs: [
                Tab(text: "주관식"),
                Tab(text: "객관식"),
              ],
            ),
        ),
        body: TabBarView(children: [ 
          Container(
            child: ListView(children: [ problemSection, answerSection, submitButton],)
          ),
         
           Container(
            child: ListView(children: [ problemSection, multipleChoice, submitButton],)
          ),
          ],
        ),
      ),
      )
    );
  }
}
