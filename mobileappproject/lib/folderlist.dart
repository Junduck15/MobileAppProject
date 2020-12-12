
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileappproject/login.dart';
import 'package:mobileappproject/problems_infolder.dart';

import 'add.dart';
import 'profile.dart';

class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<dynamic> problemTypes = [];
  int a;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    void _showDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final newTypeController = TextEditingController();
          return AlertDialog(
            title: Text("문제 그룹 생성"),
            content: Container(
              height: 80,
              child: Column(
                children: [
                  Text("생성할 문제 그룹 이름을 입력해주세요."),
                  TextField(
                    controller: newTypeController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("취소", style: TextStyle(color: Colors.black38)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("생성"),
                onPressed: () {
                  firestore
                      .collection('users')
                      .doc(_auth.currentUser.uid)
                      .update({
                    "problemTypes":
                        FieldValue.arrayUnion([newTypeController.text]),
                  });
                  firestore
                      .collection('users')
                      .doc(_auth.currentUser.uid)
                      .collection('problemType');
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Container(
            height: 32,
            child: Image.network(
              'https://ifh.cc/g/b7RiPf.png',
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.perm_identity,
              color: Colors.white,
              size: 28,
              semanticLabel: 'menu',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showDialog();
                },
              );
            }),
          ]),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                  child: Column(children: <Widget>[
        SizedBox(height: 20.0),
        Container(
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(_auth.currentUser.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data.data == null ||
                    snapshot.data.data()["problemTypes"] == null) {
                  problemTypes = [];
                } else {
                  problemTypes = snapshot.data.data()["problemTypes"];
                }

                return GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: GestureDetector(
                            onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Problems_infolderPage(
                                              foldername: problemTypes[index],
                                            )),
                                  )
                                },
                            child: Card(
                              //color: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: maincolor, width: 2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.0, 20.0, 0.0, 15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Icon(Icons.collections_bookmark,
                                                    size: 23, color: maincolor),
                                                SizedBox(
                                                  width: 7,
                                                ),
                                                Container(
                                                  width: 88,
                                                  child: Text(
                                                    (problemTypes[index]),
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                      _simplePopup(
                                                          problemTypes[index]),
                                                    ])),
                                              ]),
                                          SizedBox(height: 8.0),
                                          Divider(
                                            height: 1.0,
                                            color: maincolor,
                                            indent: 10,
                                            endIndent: 10,
                                          ),
                                          SizedBox(height: 20.0),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('    문제 수 : ',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                    )),
                                                problemCount(context,
                                                    problemTypes[index]),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )));
                  },
                  itemCount: problemTypes.length,
                );
              }),
        )
      ])))),
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add()));
        },
        child: Icon(Icons.border_color),
        backgroundColor: maincolor,
      ),
    );
  }

  Widget problemCount(BuildContext context, String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser.uid)
          .collection(type)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return Text(
          snapshot.data.docs.length.toString(),
          style: TextStyle(
            fontSize: 17,
          ),
        );
      },
    );
  }

  Widget _simplePopup(String foldername) => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("폴더 삭제"),
          ),
        ],
        onSelected: (value) {
          deleteDoc(foldername);
        },
        icon: Icon(Icons.more_vert),
        offset: Offset(0, 100),
      );

  void deleteDoc(String foldername) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection(foldername)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .update({
      "problemTypes": FieldValue.arrayRemove([foldername])
    }).then((value) {
      print("delete");
    }).catchError((error) {
      print(error);
    });
  }
}
