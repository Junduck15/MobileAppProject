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
      ),
      body: SafeArea(
          child: Container(
              width: 600.0,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 50),
                    width: 180.0,
                    height: 180.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: NetworkImage(image),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(100.0)),
                      color: Colors.transparent,
                    ),
                  ),
                  Divider(
                    height: 1.5,
                    color: maincolor,
                    indent: 30,
                    endIndent: 30,
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Row(children: <Widget>[
                        SizedBox(
                          width: 35,
                        ),
                        Icon(
                          Icons.person,
                          color: maincolor,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          auth.currentUser.uid,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ])),
                  Divider(
                    height: 1.5,
                    color: maincolor,
                    indent: 30,
                    endIndent: 30,
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Row(children: <Widget>[
                        SizedBox(
                          width: 35,
                        ),
                        Icon(
                          Icons.alternate_email,
                          color: maincolor,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          temp,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ])),
                  Divider(
                    height: 1.5,
                    color: maincolor,
                    indent: 30,
                    endIndent: 30,
                  ),
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      width: 300,
                      child: Container(
                        height: 50,
                        child: RaisedButton(
                          color: maincolor,
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                          onPressed: () {
                            auth.signOut();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()));
                          },
                        ),
                      )),
                ],
              ))),
    );
  }
}
