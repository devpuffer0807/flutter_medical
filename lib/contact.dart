import 'package:flutter/material.dart';
import 'package:iraqpvc/application_localizations.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text(ApplicationLocalizations.of(context).translate('title_contact')),
        backgroundColor: Color.fromRGBO(0, 0, 128,10),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle
            ),
          child: Text(ApplicationLocalizations.of(context).translate('contact_text'),
          style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }
}
