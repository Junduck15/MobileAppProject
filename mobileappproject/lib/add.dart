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
  final FirebaseAuth id;

  const Add({Key key, this.id}) : super(key: key);
  _Add createState() => _Add(id: id);
}

class _Add extends State<Add> {
  File _image;
  FirebaseAuth id;
  var imageString;
  String username;
  _Add({this.id});
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final problem = TextEditingController();
    final answer = TextEditingController();
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
    Widget buttonSection = Container(
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                icon: Icon(Icons.picture_as_pdf_outlined),
                onPressed: () async {
                  await getImage();
                }),
          ),
          const Divider(
            color: Colors.black,
            height: 1.0,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Text('정답'),
          ),
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
          'creator': id.currentUser.uid,
          'isShared': isSwitched
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Added(problem: problem.text, answer: answer.text)),
        );
      },
    ));

    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            '문제 입력',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: ListView(
          children: <Widget>[buttonSection, submitButton],
        ),
      ),
    );
  }
}
