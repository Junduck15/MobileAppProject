import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'add.dart';
import 'quiz.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  final String title = 'Sign In & Out';
  @override
  State<StatefulWidget> createState() => _SignInPageState();
}
class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Image.network('http://handong.edu/site/handong/res/img/logo.png'),
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
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 8.0),
                  alignment: Alignment.center,
                  child: SignInButtonBuilder(
                    text: "Guest",
                    icon: Icons.person_outline,
                    backgroundColor: Colors.grey,
                    onPressed: () async {
                      await _signInAnonymously();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Quiz()),
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
            )));
  }

  Future _signInAnonymously() async {
    try {
      user = (await _auth.signInAnonymously()).user;

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Signed in Anonymously as user ${user.uid}"),
      ));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign in Anonymously"),
      ));
    }

    return Future.delayed(Duration(seconds: 3));
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
    return Card(
      child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 8.0),
                alignment: Alignment.center,
                child: SignInButton(
                  Buttons.GoogleDark,
                  text: "Google",
                  onPressed: () async {
                    await _signInWithGoogle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Add(id: _auth)),
                    );
                  },
                ),
              ),
            ],
          )),
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
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Sign In ${user.uid} with Google"),
      ));
    } catch (e) {
      print(e);

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign in with Google: ${e}"),
      ));
    }
  }
}
