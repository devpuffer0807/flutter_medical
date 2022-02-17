import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:iraqpvc/application_localizations.dart';
import 'package:iraqpvc/faq.dart';
import 'package:iraqpvc/home.dart';
import 'package:iraqpvc/about.dart';
import 'package:iraqpvc/advreaction.dart';
import 'package:iraqpvc/services/analytics_service.dart';
import 'package:iraqpvc/ui/reporter.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'application_localizations.dart';
import 'contact.dart';

GetIt locator = GetIt.instance;
Future<void> main() async {
  locator.registerLazySingleton(() => AnalyticsService());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  new Future.delayed(const Duration(seconds: 2), () {
    runApp(MyApp());
  });
}



class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setState(() {
      state.locale = newLocale;
    });
  }
}

class _MyAppState extends State<MyApp> {
  Locale locale = Locale('ar', 'AR');

  String messageTitle = "Empty";
  String notificationAlert = "alert";

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    AwesomeNotifications().initialize(
        'resource://drawable/ic_notification',
        [
          NotificationChannel(
              channelKey: 'key1',
              channelName: 'Proto Coders Point',
              channelDescription: "Notification example",
              defaultColor: Colors.transparent,
              ledColor: Colors.transparent,
              playSound: true,
              enableLights:true,
              enableVibration: true
          )
        ]
    );

    _firebaseMessaging.configure(
      onMessage: (message) async{
        AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: 1,
                channelKey: 'key1',
                title: message["notification"]["title"],
                body: message["notification"]["body"]
            )
        );

      },
      onResume: (message) async{
        setState(() {
          messageTitle = message["data"]["title"];
          notificationAlert = "Application opened from Notification";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
      locale:  locale,
      title: 'MedSafety  السلامة الدوائية',
      // List all of the app's supported locales here
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'AR')
      ],

      localizationsDelegates: [
        ApplicationLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocaleLanguage in supportedLocales) {
          if (supportedLocaleLanguage.languageCode == locale.languageCode &&
              supportedLocaleLanguage.countryCode == locale.countryCode) {
            return supportedLocaleLanguage;
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child,
        );
      },
      navigatorObservers: [locator<AnalyticsService>().getAnalyticsObserver()],

      home: Home(),
      //home: Patient(title: 'Adverse Reaction Report'),
      routes: <String, WidgetBuilder>{
        '/About': (context) => About(),
        '/AdvReaction': (context) => AdvReaction(),
        '/Reporter': (context) => Reporter(),
        '/Faq': (context) => Faq(),
        '/Contact': (context) => Contact(),
      },
    ));
  }
}
