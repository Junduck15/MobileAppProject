import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:mobileappproject/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'main.dart';

class Profile extends StatefulWidget {
  Profile({
    Key key,
  }) : super(key: key);

  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  bool isSwitched = false;
  int notiHour = 0;
  int notiMinute = 0;
  var timeFormat = NumberFormat("00", "en_US");

  Future<void> getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isSwitched = prefs.getBool('dailyQuizNotification') ?? false;
      notiHour = prefs.getInt('notiHour') ?? 10;
      notiMinute = prefs.getInt('notiMinute') ?? 00;
    });
  }

  @override
  void initState() {
    getSharedPreferences();
    super.initState();
  }

  Future<void> _scheduleDailyNotification(int hour, int minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        '데일리 퀴즈 도착!',
        '오늘도 100점 도전~',
        _nextInstanceOfTenAM(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'daily notification channel id',
              'daily notification channel name',
              'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    String temp =
        auth.currentUser.email == null ? 'Anonymous' : auth.currentUser.email;
    String image = auth.currentUser.photoURL == null
        ? 'https://ifh.cc/g/PZ4pEO.png'
        : auth.currentUser.photoURL;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('My Page', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
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
                  auth.currentUser.displayName,
                  style: TextStyle(
                    fontSize: 18,
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
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 35,
                        ),
                        Icon(
                          Icons.alarm,
                          color: maincolor,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          '데일리 퀴즈 알람',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Transform.scale(
                            scale: 1.2,
                            child: Switch(
                              value: isSwitched,
                              onChanged: (value) {
                                if (value == true) {
                                  Future<TimeOfDay> selectedTime =
                                      showTimePicker(
                                    initialTime: TimeOfDay(
                                        hour: notiHour, minute: notiMinute),
                                    initialEntryMode: TimePickerEntryMode.input,
                                    context: context,
                                    helpText: '설정한 시간에 매일 알림이 도착합니다.',
                                  );
                                  selectedTime.then((time) {
                                    if (time != null) {
                                      _scheduleDailyNotification(
                                          time.hour, time.minute);
                                      setState(() {
                                        prefs.setInt('notiHour', time.hour);
                                        prefs.setInt('notiMinute', time.minute);
                                        notiHour = prefs.getInt('notiHour');
                                        notiMinute = prefs.getInt('notiMinute');
                                        isSwitched = value;
                                        prefs.setBool(
                                            'dailyQuizNotification', value);
                                      });
                                      final snackBar = SnackBar(
                                        content: Text(
                                          '매일 ' +
                                              timeFormat
                                                  .format(notiHour)
                                                  .toString() +
                                              ':' +
                                              timeFormat
                                                  .format(notiMinute)
                                                  .toString() +
                                              '에 데일리 퀴즈 알림이 도착합니다.',
                                        ),
                                      );
                                      _scaffoldKey.currentState
                                          .showSnackBar(snackBar);
                                    }
                                  });
                                } else {
                                  _cancelNotification();
                                  setState(() {
                                    isSwitched = value;
                                    prefs.setBool(
                                        'dailyQuizNotification', value);
                                  });
                                }
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                            )),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    isSwitched == true? Row(children: <Widget>[
                      SizedBox(
                        width: 78,
                      ),
                      Text(
                        '알람 예약:  매일 ' +
                            timeFormat.format(notiHour).toString() +
                            ':' +
                            timeFormat.format(notiMinute).toString(),
                      ),
                    ]) : Container()

                  ])),
          Divider(
            height: 1.5,
            color: maincolor,
            indent: 30,
            endIndent: 30,
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                    GoogleSignIn().signOut();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                ),
              )),
        ],
      ),
    );
  }
}
