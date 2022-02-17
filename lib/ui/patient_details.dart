import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iraqpvc/application_localizations.dart';
import 'package:iraqpvc/model/patient.dart';
import 'package:iraqpvc/util/sharedPref.dart';

class PatientDetails extends StatefulWidget {
  final TabController tabController;
  final ValueChanged<int> parentAction;

  PatientDetails({this.tabController, this.parentAction});

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  int _genderValue = -1;
  SharedPref sharedPref = SharedPref();
  Patient patient = Patient();

  TextEditingController name = new TextEditingController();
  TextEditingController age = new TextEditingController();
  TextEditingController weight = new TextEditingController();
  TextEditingController height = new TextEditingController();
  TextEditingController medical_notes = new TextEditingController();
  String selected_age_option;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  var _source = "Patient_en";

  loadSharedPrefs() async {
    try {
      if(ApplicationLocalizations.of(context).appLocale.languageCode == 'ar')
        _source = "Patient_ar";

      patient = Patient.fromJson(await sharedPref.read(_source));
      log("Patient on loadsharedprefs: " + _source+ " : " + patient.toJson().toString());

      setState(() {
        name.text = patient.name;
        age.text = patient.age;
        weight.text = patient.weight;
        height.text = patient.height;
        medical_notes.text = patient.medical_notes;
        selected_age_option = patient.age_option;
        if (patient.gender == 'male'){
          _genderValue = 0;
        }else{
          _genderValue = 1;
        }
      });
    } catch (Exception) {
      log("No Patient details found " + Exception.toString() );
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

  void _handleGenderChange(int value) {
    setState(() {
      FocusScope.of(context).requestFocus(new FocusNode());
      _genderValue = value;
      if (value == 0){
        patient.gender = "male";
      }else{
        patient.gender = "female";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var ageOptions = new List<String>.from(
        ApplicationLocalizations.of(context).translate("age_options"));
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
      child: Form(
      key: _key,
      autovalidateMode : AutovalidateMode.disabled,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          TextFormField(
            controller: name,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              prefixIcon: Icon(Icons.person),
              labelText: ApplicationLocalizations.of(context)
                  .translate("patient_name"),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return ApplicationLocalizations.of(context)
                    .translate("error_mandatory_patient_name").toString();
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                patient.name = value;
              });
            },
          ),
          SizedBox(
            height: 15.0,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.wc, color: Colors.black, size: 32),
              Text(ApplicationLocalizations.of(context).translate("gender")),
              Radio(
                value: 0,
                groupValue: _genderValue,
                onChanged: _handleGenderChange,
              ),
              Text(
                ApplicationLocalizations.of(context).translate("male"),
                style: new TextStyle(fontSize: 16.0),
              ),
              Radio(
                value: 1,
                groupValue: _genderValue,
                onChanged: _handleGenderChange,
              ),
              new Text(
                ApplicationLocalizations.of(context).translate("female"),
                style: new TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextFormField(
                  controller: age,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText:
                        ApplicationLocalizations.of(context).translate("age"),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return ApplicationLocalizations.of(context)
                          .translate("error_mandatory_patient_age").toString();
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      patient.age = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: DropdownButtonFormField(
                    value: selected_age_option,
                    items: ageOptions.map((e) {
                      return DropdownMenuItem<String>(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: ApplicationLocalizations.of(context)
                          .translate("age_option")
                          .toString(),
                    ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return ApplicationLocalizations.of(context)
                          .translate("error_mandatory_patient_age_option").toString();
                  }
                  return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      patient.age_option = value;
                    });
                  },
                  onTap: (){
                    FocusManager.instance.primaryFocus.unfocus();
                  },
                ),
              )
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: weight,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: ApplicationLocalizations.of(context)
                          .translate("weight")
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
                        patient.weight = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Flexible(
                  child: TextFormField(
                    controller: height,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: ApplicationLocalizations.of(context)
                          .translate("height")
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
                        patient.height = value;
                      });
                    },
                  ),
                )
              ]),
          SizedBox(
            height: 15.0,
          ),
          TextFormField(
            controller: medical_notes,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              labelText: ApplicationLocalizations.of(context)
                  .translate("medical_history")
                  .toString(),
              hintText: ApplicationLocalizations.of(context)
                  .translate("medical_history")
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
                patient.medical_notes = value;
              });
            },
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RaisedButton.icon(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      widget.tabController.animateTo(0);
                      widget.parentAction(0);
                    },
                    label: Text(ApplicationLocalizations.of(context)
                        .translate("prev")
                        .toString()),
                    color: Colors.lightGreen,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    )),
                RaisedButton.icon(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (!_key.currentState.validate()) {
                      _key.currentState.save();
                      return false;
                      } else {
                      // validation error
                      setState(() {
                      _validate = true;
                      });
                      }
                      sharedPref.save(_source, patient);
                      log("Patient details on save: " + _source+ " : " + patient.toJson().toString());
                      widget.tabController.animateTo(2);
                      widget.parentAction(2);
                    },
                    label: Text(ApplicationLocalizations.of(context)
                        .translate("next")
                        .toString()),
                    color: Colors.lightGreen,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ))
              ]),
        ]))
      ),
    );
  }
}
