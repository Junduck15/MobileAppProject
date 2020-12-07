import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappproject/login.dart';
import 'package:mobileappproject/main.dart';
import 'package:translator/translator.dart';


import 'add.dart';

String out = "Asd";

class Problems_infolderPage extends StatefulWidget {
  final String foldername;

  Problems_infolderPage({Key key, @required this.foldername}) : super(key: key);

  @override
  _Problems_infolderPage createState() => _Problems_infolderPage();
}

class _Problems_infolderPage extends State<Problems_infolderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String dropdownValue = '최신순';

  @override

  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection(widget.foldername);

    switch (dropdownValue) {
      case "최신순":
        query = query.orderBy('createdTime', descending: false);
        break;
      case "오래된순":
        query = query.orderBy('createdTime', descending: true);
        break;
    }


     trans(String pro_text) async {
      final translator = GoogleTranslator();

      //final input = "Because the sports club was established _______ for the residents of the community, its monthly fee is a little higher than most other clubs.";

      // prints Hello. Are you okay?

      //var translation = await translator.translate("__________,a few errors in pronunciation, the speech the foreigner gave was perfect.", to: 'ko');
      var translation = await translator.translate(pro_text, to: 'ko');

      out = translation.toString();
      print(translation);
      print(out);
      // prints Dart jest bardzo fajny!



      return out;
      // prints exemplo
    }



    void _hi(String pro_text) async{
      String a = await trans(pro_text);
      print('asd');
      print(a);
      setState(() {
        out = a;
      });
      print(out);
    }


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
                    SizedBox(height: 18,),
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
          child: Padding(
              padding:
              const EdgeInsets.only(left: 25, right: 25),
              child: DropdownButton<String>(
                value: dropdownValue,
                style: TextStyle(color: Colors.black, fontSize: 15),
                underline: Container(),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: <String>['최신순', '오래된순']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
          )),
        SizedBox(height: 7.0),
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
                            padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
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
                                            20.0, 0.0, 15.0, 13.0),
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
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                          Container(
                                                            height: 25.0,
                                                            width: 65,
                                                            color: Colors
                                                                .transparent,
                                                            child:
                                                                new Container(
                                                                    decoration:
                                                                        new BoxDecoration(
                                                                      color: Colors
                                                                          .orangeAccent,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    child:
                                                                        new Center(
                                                                      child: new Text(
                                                                          "주관식",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w500)),
                                                                    )),
                                                          ),
                                                          //Text(await trans()),
                                                          SizedBox(
                                                            height: 6,
                                                          ),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text('Q.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          27,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          maincolor,
                                                                    )),
                                                                Flexible(
                                                                    child: Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                        child: Text(stream.data.docs[index]['problemtext'],
                                                                            style: TextStyle(
                                                                              fontSize: 17,
                                                                            ))))
                                                              ]),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    stream
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                            [
                                                                            'createdTime']
                                                                        .toDate()
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontStyle:
                                                                            FontStyle.italic)),
                                                                Text(' 에 등록됨 ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .grey)),
                                                              ]),
                                                        ])
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                          Container(
                                                            height: 25.0,
                                                            width: 65,
                                                            color: Colors
                                                                .transparent,
                                                            child:
                                                                new Container(
                                                                    decoration:
                                                                        new BoxDecoration(
                                                                      color: Colors
                                                                          .lightGreen,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    child:
                                                                        new Center(
                                                                      child: new Text(
                                                                          "객관식",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w500)),
                                                                    )),
                                                          ),
                                                          SizedBox(
                                                            height: 6,
                                                          ),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text('Q.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          27,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          maincolor,
                                                                    )),
                                                                Flexible(
                                                                    child: Padding(
                                                                        padding: EdgeInsets.fromLTRB(10, 9, 20, 10),
                                                                        child: Text(stream.data.docs[index]['problemtext'],
                                                                            style: TextStyle(
                                                                              fontSize: 17,
                                                                            ))))
                                                              ]),
                                                        RaisedButton(
                                                          child: Text('aqqt'),
                                                          onPressed: (){
                                                            _hi(stream.data.docs[index]['problemtext']);
                                                            print('aㅁㅇ'+out);
                                                          },
                                                        ),
                                                        Text(out),
                                                          Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          32,
                                                                          9,
                                                                          20,
                                                                          10),
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Divider(
                                                                      height:
                                                                          1.0,
                                                                      color:
                                                                          maincolor,
                                                                      indent: 0,
                                                                      endIndent:
                                                                          0,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          25,
                                                                    ),
                                                                    Text(
                                                                        '1)  ' +
                                                                            stream.data.docs[index]['multipleWrongAnswers'][
                                                                                0],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        )),
                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                        '2)  ' +
                                                                            stream.data.docs[index]['multipleWrongAnswers'][
                                                                                1],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        )),
                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                        '3)  ' +
                                                                            stream.data.docs[index]['multipleWrongAnswers'][
                                                                                2],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        )),
                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                        '4)  ' +
                                                                            stream.data.docs[index][
                                                                                'answer'],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        )),
                                                                  ])),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    stream
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                            [
                                                                            'createdTime']
                                                                        .toDate()
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontStyle:
                                                                            FontStyle.italic)),
                                                                Text(' 에 등록됨 ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .grey)),
                                                              ]),
                                                        ])
                                            ]),
                                      )
                                    ])));
                      },
                    );
                }))
      ])))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add()));
        },
        child: Icon(Icons.add),
        backgroundColor: maincolor,
      ),
    );
  }
}
