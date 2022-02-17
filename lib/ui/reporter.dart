import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iraqpvc/application_localizations.dart';
import 'package:iraqpvc/model/profile.dart';
import 'package:iraqpvc/util/sharedPref.dart';

// ignore: must_be_immutable
class Reporter extends StatefulWidget {
  TabController tabController;
  final ValueChanged<int> parentAction;

  Reporter({this.tabController, this.parentAction});

  @override
  _ReporterState createState() => _ReporterState();
}

class _ReporterState extends State<Reporter> {

  SharedPref sharedPref = SharedPref();
  Profile userSave = Profile();
  TextEditingController name = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  TextEditingController emailtxt = new TextEditingController();
  TextEditingController org = new TextEditingController();
  String selectedCity, selectedProfession;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  var _source = "profile_en";

  loadSharedPrefs() async {
    try {
      log("lang: "+ ApplicationLocalizations.of(context).appLocale.languageCode);

      if(ApplicationLocalizations.of(context).appLocale.languageCode == 'ar')
        _source = "profile_ar";

      userSave = Profile.fromJson(await sharedPref.read(_source));

      log("user on loadsharedprefs: " + userSave.toJson().toString());

      setState(() {
        name.text = userSave.name;
        phone.text = userSave.phone;
        emailtxt.text = userSave.email;
        org.text = userSave.org;
        selectedCity = userSave.city;
        selectedProfession = userSave.profession;
      });
    } catch (Exception) {
      log("No Sender details found");
    }
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    var professions = new List<String>.from(
        ApplicationLocalizations.of(context).translate("professions"));
    var cities = new List<String>.from(
        ApplicationLocalizations.of(context).translate("cities"));

    return Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Form(
              key: _key,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: name,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(Icons.person),
                        labelText: ApplicationLocalizations.of(context)
                            .translate("reporter_name"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          userSave.name = value;
                        });
                      },
                      validator: (String value) {
                        if (value == null || value.isEmpty) {
                          return ApplicationLocalizations.of(context)
                              .translate("error_mandatory_reporter_name").toString();
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      controller: phone,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(Icons.phone),
                        labelText: ApplicationLocalizations.of(context)
                            .translate("phone")
                            .toString(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          userSave.phone = value;
                        });
                      },
                      validator: (String value) {
                        if (value == null || value.isEmpty) {
                          return ApplicationLocalizations.of(context)
                              .translate("error_mandatory_reporter_phone").toString();
                        }
                        return null;
                      },
                    ),
                    /*
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      controller: emailtxt,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(Icons.email),
                        labelText: ApplicationLocalizations.of(context)
                            .translate("email")
                            .toString(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          userSave.email = value;
                        });
                      },
                    ),
                    */
                    SizedBox(
                      height: 15.0,
                    ),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(Icons.place),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: ApplicationLocalizations.of(context)
                            .translate("city")
                            .toString(),
                      ),
                      value: selectedCity,
                      onTap: (){
                        FocusManager.instance.primaryFocus.unfocus();
                      },
                      onChanged: (String newValue) {
                        setState(() {
                          selectedCity = newValue;
                          userSave.city = selectedCity;
                        });
                      },
                      validator: (String value) {
                        if (value == null || value.isEmpty) {
                          return ApplicationLocalizations.of(context)
                              .translate("error_mandatory_reporter_city").toString();
                        }
                        return null;
                      },
                      items: cities.map((e) {
                        return DropdownMenuItem<String>(
                          child: Text(e),
                          value: e,
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      controller: org,
                      autofocus: false,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(Icons.group),
                        labelText: ApplicationLocalizations.of(context)
                            .translate("org")
                            .toString(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          userSave.org = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(Icons.portrait),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: ApplicationLocalizations.of(context)
                            .translate("profession")
                            .toString(),
                      ),
                      items: professions.map((e) {
                        return DropdownMenuItem<String>(
                          child: Text(e),
                          value: e,
                        );
                      }).toList(),
                      value: selectedProfession,
                      onChanged: (String newValue) {
                        setState(() {
                          selectedProfession = newValue;
                          userSave.profession = selectedProfession;
                        });
                      },
                      onTap: (){
                        FocusManager.instance.primaryFocus.unfocus();
                      },
                      validator: (String value) {
                        if (value == null || value.isEmpty) {
                          return ApplicationLocalizations.of(context)
                              .translate("error_mandatory_reporter_profession").toString();
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton.icon(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () async {
                              if (!_key.currentState.validate()) {
                                _key.currentState.save();
                                return false;
                              } else {
                                // validation error
                                setState(() {
                                  _validate = true;
                                });
                              }
                              log("user on save: " + userSave.toJson().toString() + " source: " + _source);

                              sharedPref.save(_source, userSave);
                              widget.tabController.animateTo(1);
                              widget.parentAction(1);
                            },
                            label: Text(ApplicationLocalizations.of(context)
                                .translate("next")
                                .toString()),
                            color: Colors.lightGreen,
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            )),
                      ],
                    ),
                  ])),
        ));
  }
}
