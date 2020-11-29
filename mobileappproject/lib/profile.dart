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
        ? 'https://ifh.cc/g/PZ4pEO.png'
        : auth.currentUser.photoURL;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          Column(children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () {
                  auth.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInPage()));
                }),
          ])
        ],
      ),
      body: ListView(
        children: <Widget>[
          Image.network(
            image,
            width: 800,
          ),
          Text(
            auth.currentUser.uid,
          ),
          Text(
            temp,
          ),
        ],
      ),
    );
  }
}
