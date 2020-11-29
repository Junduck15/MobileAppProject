import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileappproject/login.dart';

class Profile extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Profile({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String temp =
        auth.currentUser.email == null ? 'Anonymous' : auth.currentUser.email;
    String image = auth.currentUser.photoURL == null
        ? 'http://handong.edu/site/handong/res/img/logo.png'
        : auth.currentUser.photoURL;
    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Main'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  auth.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInPage()));
                }),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Image.network(
              image,
              width: 800,
            ),
            Text(auth.currentUser.uid, style: TextStyle(color: Colors.white)),
            Text(temp, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
