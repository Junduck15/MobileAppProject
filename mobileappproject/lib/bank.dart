import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

List<String> problemsList = [];

class BankPage extends StatefulWidget {
  @override
  _BankPageState createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userRef = FirebaseFirestore.instance.collection('users');

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    List<dynamic> probIDs = [];

    userRef.get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        probIDs.add(doc.id);
      });
      for (int i = 0; i < probIDs.length; i++) {
        String title = "";
        firestore
            .collection("users")
            .doc(probIDs[i])
            .get()
            .then((DocumentSnapshot ds) {
          title = ds.data()["problemTypes"].toString();
          if (title != 'null') {
            title = title.substring(1, title.length - 1);
          }

          List<String> each = title.split(',');
          for (int j = 0; j < each.length; j++) {
            print(each[j].trim());
            List<dynamic> inProbIDs = [];
            userRef
                .doc(probIDs[i])
                .collection(each[j].trim())
                .get()
                .then((snapshot) {
              snapshot.docs.forEach((doc) {
                inProbIDs.add(doc.id);
                //print(doc.id);
              });
              for (int u = 0; u < inProbIDs.length; u++) {
                firestore
                    .collection("users")
                    .doc(probIDs[i])
                    .collection(each[j].trim())
                    .doc(inProbIDs[u])
                    .get()
                    .then((DocumentSnapshot ls) {
                  problemsList.add(ls.data()['problemtext'].toString());
                });
              }
            });
          }
        });
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: Text('문제 은행'),
        ),
        body: Text(problemsList.toString()));
  }
}
