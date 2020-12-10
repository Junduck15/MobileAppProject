import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileappproject/QuizMenu.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dailyQuiz.dart';
import 'profile.dart';
import 'bank.dart';
import 'folderlist.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  int _currentIndex = 0;

  final List<Widget> _children = [FolderPage(), QuizMenu(), BankPage()];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => HomePage(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject(){
    selectNotificationSubject.stream.listen((String payload) async {
      print('clicked!');
      List<dynamic> problemTypes = [];
      List<dynamic> problemTypesWithProblems = [];
      FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser.uid)
          .snapshots()
          .listen((data) async {
        data.data()["problemTypes"] != null
            ? problemTypes = data.data()["problemTypes"]
            : problemTypes = [];

        for(var i = 0; i < problemTypes.length; i++){
          FirebaseFirestore.instance
              .collection("users")
              .doc(auth.currentUser.uid)
              .collection(problemTypes[i])
              .snapshots()
              .listen((data) async {
                if (data.docs.length > 0) {
                  problemTypesWithProblems.add(problemTypes[i]);
                }
                if(i == problemTypes.length - 1){
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => DailyQuiz(
                          problemTypes: problemTypesWithProblems,
                        )),
                  );
                }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _children[_currentIndex], bottomNavigationBar: _BottomBar());
  }

  Widget _BottomBar() {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _onTap,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('오답노트'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.description),
            title: Text('Quiz'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            title: Text('문제은행'),
          )
        ]);
  }
}
