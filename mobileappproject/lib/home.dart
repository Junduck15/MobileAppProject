
import 'package:flutter/material.dart';
import 'package:mobileappproject/QuizMenu.dart';


import 'profile.dart';
import 'bank.dart';
import 'folderlist.dart';

class HomePage extends StatefulWidget {

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;

  final List<Widget> _children = [FolderPage(), QuizMenu(), BankPage()];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: _children[_currentIndex],
        bottomNavigationBar: _BottomBar()
    );
  }


  Widget _BottomBar(){
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
