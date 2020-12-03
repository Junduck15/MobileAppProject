import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';

class Problems_infolderPage extends StatefulWidget {
  final String foldername;

  Problems_infolderPage({Key key, @required this.foldername}) : super(key: key);

  @override
  _Problems_infolderPage createState() => _Problems_infolderPage();
}

class _Problems_infolderPage extends State<Problems_infolderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection(widget.foldername);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.foldername,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Container(
                    child: Column(children: <Widget>[
          SizedBox(height: 20.0),
          Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: query.snapshots(),
                  builder: (context, stream) {
                    if (stream.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (stream.data == null) return CircularProgressIndicator();

                    if (stream.hasError) {
                      return Center(child: Text(stream.error.toString()));
                    } else
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: stream.data.size,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              padding: EdgeInsets.only(top: 3),
                              child: Card(
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    side:
                                        BorderSide(color: maincolor, width: 2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.0, 0.0, 0.0, 15.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  stream.data.docs[index]
                                                              ['isMultiple'] ==
                                                          false
                                                      ? Text(
                                                          '문제. ' +
                                                              stream.data.docs[
                                                                      index][
                                                                  'problemtext'],
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                          ))
                                                      : Text(
                                                      '문제. ' +
                                                          stream.data.docs[
                                                          index][
                                                          'problemtext'],
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                      )),
                                                ]))
                                      ])));
                        },
                      );
                  }))
        ])))));
  }
}
