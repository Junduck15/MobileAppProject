import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobileappproject/home.dart';
import 'add.dart';
import 'quiz.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Color maincolor = const Color.fromRGBO(86, 171, 190, 1.0);

class SignInPage extends StatefulWidget {
  final String title = 'Sign In & Out';

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  @override
  void initState() {
    super.initState();
    _signInSilently();
  }

  Future _signInSilently() async {
    bool isSignedIn = await GoogleSignIn().isSignedIn();
    if (isSignedIn) {
      GoogleSignInAccount googleUser = await GoogleSignIn().signInSilently();
      UserCredential userCredential;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final GoogleAuthCredential googleAuthCredential =
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(googleAuthCredential);

      final user = userCredential.user;

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
      //print(GoogleSignIn().currentUser.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: maincolor,
      body: Builder(builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            SizedBox(height: 200),
            Container(
                height: 80,
                child: Image.network(
                  'https://ifh.cc/g/b7RiPf.png',
                )),
            SizedBox(height: 200),
            _OtherProvidersSignInSection(),
            _AnonymouslySignInSection(),
          ],
        );
      }),
    );
  }
}

class _AnonymouslySignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AnonymouslySignInSectionState();
}

class _AnonymouslySignInSectionState extends State<_AnonymouslySignInSection> {
  bool _success;
  String _userID;
  User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              alignment: Alignment.center,
              child: SignInButtonBuilder(
                text: "Guest",
                textColor: Colors.grey,
                icon: Icons.person_outline,
                iconColor: Colors.grey,
                backgroundColor: Colors.white,
                onPressed: () async {
                  await _signInAnonymously();
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                  );
                },
              ),
            ),
            Visibility(
              visible: _success == null ? false : true,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _success == null
                      ? ''
                      : (_success
                          ? 'Successfully signed in, uid: ' + _userID
                          : 'Sign in failed'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          ],
        ));
  }

  Future _signInAnonymously() async {
    try {
      user = (await _auth.signInAnonymously()).user;

      addUser(user.uid, user.displayName);


      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Signed in Anonymously as user ${user.uid}"),
      ));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign in Anonymously"),
      ));
    }

    return Future.delayed(Duration(seconds: 1));
  }
}

Future toHome() async {}

class _OtherProvidersSignInSection extends StatefulWidget {
  _OtherProvidersSignInSection();

  @override
  State<StatefulWidget> createState() => _OtherProvidersSignInSectionState();
}

class _OtherProvidersSignInSectionState
    extends State<_OtherProvidersSignInSection> {
  GoogleSignInAccount googleUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: SignInButton(
            Buttons.GoogleDark,
            text: "Google",
            onPressed: () async {
              _signInWithGoogle();
            },
          ),
        ),
      ],
    );
  }

  Future _signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final GoogleAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(googleAuthCredential);
      }

      final user = userCredential.user;

      addUser(user.uid, user.displayName);

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Sign In ${user.uid} with Google"),
      ));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e);

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign in with Google: ${e}"),
      ));
    }
  }
}

Future<void> addUser(String uid, String displayname) {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  users.doc(uid).get().then((doc) {
    if (doc.exists) {
      DocumentReference ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);
      ref.update({
        'displayname': displayname,
      });
    }
    else {
      DocumentReference ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);
      ref.set({
        'displayname': displayname,
      });
      return users
          .doc(uid)
          .set({

      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }
  });
}
