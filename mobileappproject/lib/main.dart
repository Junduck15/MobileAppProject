import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'home.dart';
import 'login.dart';
import 'add.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  final NotificationAppLaunchDetails notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    });
  final MacOSInitializationSettings initializationSettingsMacOS =
  MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
        selectNotificationSubject.add(payload);
      });

  runApp(App(notificationAppLaunchDetails,));
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  // final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
}

class App extends StatefulWidget {
  const App(
      this.notificationAppLaunchDetails, {
        Key key,
      }) : super(key: key);

  final NotificationAppLaunchDetails notificationAppLaunchDetails;
  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;


  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return Container(
        child: Text('error'),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Container(
        child: CircularProgressIndicator(),
      );
    }

    return MyApp();
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(86, 171, 190, 1.0),
      ),

      // home: HomePage(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => SignInPage(),
        '/home': (context) => HomePage(),
        '/add': (context) => Add(),
      },
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == '/login') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => SignInPage(),
        fullscreenDialog: true,
      );
    }
  }
}
