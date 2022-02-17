import 'package:flutter/material.dart';
import 'package:iraqpvc/application_localizations.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text(ApplicationLocalizations.of(context).translate('title_about')),
        backgroundColor: Color.fromRGBO(0, 0, 128,10),
      ),
      body: SingleChildScrollView(
    padding: EdgeInsets.all(5),
    child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle
            ),
          child: Text(ApplicationLocalizations.of(context).translate('about_text')),
          )
        ],
      ),
      ),
    );
  }
}
