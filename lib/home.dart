import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:iraqpvc/application_localizations.dart';
import 'package:iraqpvc/main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

//final List<Article> _allNews = Article.allNews();
//List<Article> _allNews;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(0, 0, 128, 10),
        title: Text(
          ApplicationLocalizations.of(context).translate('app_title'),
          style: new TextStyle(fontSize: 18.0, color: Colors.yellow),
        ),
        titleSpacing: -5,
      ),
      drawer: buildDrawer(),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('news').orderBy("createdat", descending: true).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return new ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, i) {
                        return Card(
                            color: Colors.deepPurple[100],
                            child: new Column(
                              children: <Widget>[
                                new ListTile(
                                  trailing: new Image.network(
                                    snapshot.data.docs[i].get('image'),
                                    // "https://static.wixstatic.com/media/9b9593_3d57fe8f45ff4b549f3ac1f8d50f95ad~mv2.jpg",
                                    fit: BoxFit.cover,
                                    width: 100.0,
                                  ),

                                  title: new Text(
                                    snapshot.data.docs[i].get('title'),
                                    style: new TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                  //trailing: ,
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              child: PhotoView(
                                                  imageProvider: NetworkImage(snapshot
                                                        .data.docs[i]
                                                        .get('image')
                                                      ),
                                                    ),
                                              ),
                                           )
                                        );
                                  },
                                )
                              ],
                            ));
                      },
                      shrinkWrap: true,
                    );
                }
              },
            )),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: FlatButton.icon(
                  icon: Icon(Icons.send),
                  padding: EdgeInsets.all(15),
                  onPressed: () {
                    Navigator.pushNamed(context, '/AdvReaction');
                  },
                  label: Text(
                    ApplicationLocalizations.of(context)
                        .translate('btn_send_report'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  color: Color.fromRGBO(0, 0, 128, 10),
                  textColor: Colors.yellow,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0))),
            ),
          ]),
    );
  }




  buildDrawer() {
    return Container(
      width: 200,
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          shrinkWrap: true,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset("assets/images/iphvc.jpg", fit: BoxFit.fitHeight),
              decoration: BoxDecoration(
                color: Color.fromRGBO(140, 255, 250, 1),
              ),
            ),
            ListTile(
              title: Text(ApplicationLocalizations.of(context)
                  .translate('menu_reporting_method'),
                  style: new TextStyle(
                      fontSize: 16.0)
              ),
              onTap: () async {
                //const url = 'https://youtu.be/mocmZGN4OMQ';
                var url = ApplicationLocalizations.of(context).translate('reporting_method_video_url').toString();
                if (await canLaunch(url) != null) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
                //Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                  ApplicationLocalizations.of(context).translate('menu_faq'),style: new TextStyle(
                  fontSize: 16.0)),
              onTap: () {
                Navigator.pushNamed(context, '/Faq');
              },
            ),
            /*
            ListTile(
              title: Text(ApplicationLocalizations.of(context)
                  .translate('menu_rating'),style: new TextStyle(
                  fontSize: 16.0)),
              onTap: () {
                RateMyApp rateMyApp = RateMyApp(
                  preferencesPrefix: 'rateMyApp_',
                  googlePlayIdentifier: 'com.zapota.iphvc',
                  minDays: 0, // Show rate popup on first day of install.
                  minLaunches: 5, // Show rate popup after 5 launches of app after minDays is passed.
                );
                rateMyApp.showRateDialog(context);
                //Navigator.pop(context);
              },
            ),*/
            // ListTile(
            //   title: Text(ApplicationLocalizations.of(context)
            //       .translate('menu_contact'),style: new TextStyle(
            //       fontSize: 16.0)),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/Contact');
            //   },
            // ),
            ListTile(
              title: Text(
                  ApplicationLocalizations.of(context).translate('menu_about'),style: new TextStyle(
                  fontSize: 16.0)),
              onTap: () {
                Navigator.pushNamed(context, '/About');
              },
            ),
            ListTile(
              title: Text(ApplicationLocalizations.of(context)
                  .translate('menu_change_lang'),style: new TextStyle(
                  fontSize: 16.0)),
              onTap: () async {
                log(Localizations.localeOf(context).languageCode);
                var locale = Localizations.localeOf(context).languageCode;
                if (locale == 'en') {
                  MyApp.setLocale(context, Locale('ar', 'AR'));
                } else {
                  MyApp.setLocale(context, Locale('en', 'US'));
                }
              },
            ),
            Image.asset("assets/images/iphvcbanner2.jpeg", fit: BoxFit.fitHeight),
          ],
        ),
      ),
    );
  }
}
