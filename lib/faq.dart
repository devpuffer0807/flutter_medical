import 'package:flutter/material.dart';
import 'package:iraqpvc/application_localizations.dart';

class Faq extends StatefulWidget {
  @override
  _FaqState createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text(ApplicationLocalizations.of(context).translate('title_faq')),
        backgroundColor: Color.fromRGBO(0, 0, 128,10),
      ),
      body: SingleChildScrollView(
    padding: EdgeInsets.all(5),
    child:Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle
            ),
          child: Text(ApplicationLocalizations.of(context).translate('faq_text'),
              style: TextStyle(fontSize: 18)),
          )
        ],
      ),
      ),
    );
  }
}
