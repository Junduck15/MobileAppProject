import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';

class BankPage extends StatefulWidget {
  @override
  _BankPage createState() => _BankPage();
}

class _BankPage extends State<BankPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('생활영어');
    Query query2 = FirebaseFirestore.instance.collection('토익');
    Query query3 = FirebaseFirestore.instance.collection('토플');
    Query query4 = FirebaseFirestore.instance.collection('기타');

    Widget _lifeEng = Container(
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
                                  side: BorderSide(color: maincolor, width: 2),
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
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                              ]))
                                    ])));
                      });
              }))
    ]));
    Widget _toeic = Container(
        child: Column(children: <Widget>[
      SizedBox(height: 20.0),
      Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: query2.snapshots(),
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
                                  side: BorderSide(color: maincolor, width: 2),
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
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                              ]))
                                    ])));
                      });
              }))
    ]));
        Widget _toefl = Container(
        child: Column(children: <Widget>[
      SizedBox(height: 20.0),
      Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: query3.snapshots(),
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
                                  side: BorderSide(color: maincolor, width: 2),
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
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                              ]))
                                    ])));
                      });
              }))
    ]));
        Widget _extra = Container(
        child: Column(children: <Widget>[
      SizedBox(height: 20.0),
      Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: query4.snapshots(),
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
                                  side: BorderSide(color: maincolor, width: 2),
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
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        ))
                                                    : Text(
                                                        '문제. ' +
                                                            stream.data
                                                                    .docs[index]
                                                                ['problemtext'],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                        )),
                                              ]))
                                    ])));
                      });
              }))
    ]));
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "문제 은행",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                  children: [Container(child:
                  Text("토익")),_toeic,Text("생활영어"),_lifeEng,Text("토플"),_toefl,Text("기타"),_extra],
                    
))));
  }
}
