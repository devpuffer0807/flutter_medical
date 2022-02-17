import 'dart:developer';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:iraqpvc/application_localizations.dart';
import 'package:iraqpvc/model/drug.dart';
import 'package:iraqpvc/model/drugs.dart';
import 'package:iraqpvc/util/gmail.dart';
import 'package:iraqpvc/util/sharedPref.dart';
import 'package:mailer2/mailer.dart';
import 'package:uuid/uuid.dart';

class DrugsForm extends StatefulWidget {
  final TabController tabController;
  final ValueChanged<int> parentAction;

  DrugsForm({this.tabController, this.parentAction});

  @override
  _DrugsFormState createState() => _DrugsFormState();
}

class _DrugsFormState extends State<DrugsForm> {
  SharedPref sharedPref = SharedPref();
  DrugList _drugList = new DrugList();
  Drug _drug = new Drug();
  final _formKey = GlobalKey<FormState>();
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  List<Drug> _drugs = new List<Drug>();
  List<String> _images = new List<String>();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  var _source = "DrugList_en";

  loadSharedPrefs() async {
    try {
      if(ApplicationLocalizations.of(context).appLocale.languageCode == 'ar')
        _source = "DrugList_ar";

      _drugList = DrugList.fromJson(await sharedPref.read(_source));
      log(_drugList.toJson().toString());
      setState(() {
        _drugList.list.length;
      });
    } catch (Exception) {
      log("No Drugs found");
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

  List<String> _selected = new List<String>();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Image.asset("assets/images/drugs.jpg"),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Ink(
                          decoration: const ShapeDecoration(
                            color: Colors.green,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                _drug = new Drug();
                              });
                              drugDialog(context, null);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Center(
                        child: Ink(
                          decoration: const ShapeDecoration(
                            color: Colors.red,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove),
                            color: Colors.white,
                            onPressed: () {
                              //sharedPref.save("DrugList", {});
                              log("selected items: " + _selected.length.toString());

                              if(_selected.length ==0){
                                return false;
                              }

                              setState(() {
                                for(String id in _selected) {
                                  _drugList.list.removeWhere((
                                      element) => element.id == id);
                                }
                              });
                              sharedPref.save(_source, _drugList);

                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4, // fixed height
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)),
                        child: ListView.builder(
                          itemCount: _drugList.list.length,
                          itemBuilder: (context, index) {
                            var _Id = _drugList.list[index].id;
                            return Card(
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 0,
                                      child: Checkbox(
                                        value: _selected.contains(_Id),
                                        onChanged: (value) {
                                          setState(() {
                                            if (_selected.contains(_Id)) {
                                              _selected.remove(_Id);
                                            } else {
                                              _selected.add(_Id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    Flexible(
                                        child: ListTile(
                                      title: new Text(_drugList.list[index].name),
                                          subtitle: (_drugList.list[index].role != null) ? Text(_drugList.list[index].role ) : null,
                                      onTap: () {
                                        log("you clicked on: " + _drugList.list[index].name);
                                        drugDialog(context, _drugList.list[index]);
                                      },
                                    ))
                                  ],
                                ));
                          },
                          shrinkWrap: true,
                        ),
                      )),
                ],
              ),

              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RaisedButton.icon(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          widget.tabController.animateTo(2);
                          widget.parentAction(2);
                        },
                        label: Text(ApplicationLocalizations.of(context)
                            .translate("prev")
                            .toString()),
                        color: Colors.lightGreen,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        )),
                    RaisedButton.icon(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          if(_drugList.list.length == 0){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  title: Text(ApplicationLocalizations.of(context)
                                      .translate("error_alert_title").toString()),
                                  content: Text( ApplicationLocalizations.of(context)
                                      .translate("error_mandatory_drug").toString()),
                                  actions: <Widget>[
                                    // usually buttons at the bottom of the dialog
                                    new FlatButton(
                                      child: Text( ApplicationLocalizations.of(context)
                                          .translate("close").toString()),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }else {
                            showLoaderDialog(context);
                            Gmail gmail = new Gmail();
                            await gmail.send2(
                                context,
                                ApplicationLocalizations
                                    .of(context)
                                    .appLocale
                                    .languageCode);
                            log("clear the text after sending.");
                          }
                        },
                        label: Text(ApplicationLocalizations.of(context)
                            .translate("send")
                            .toString()),
                        color: Colors.lightGreen,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ))
                  ]),
            ])));
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7),
              child: Text(ApplicationLocalizations.of(context)
              .translate("sending_email").toString())),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  File _image;

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    log("image path " + image.path);
    setState(() {
      _image = image;
      _images.add(image.path);
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    _drugList.addImages(image.path);
    sharedPref.save("DrugList", _drugList);
    log("image gallery path " + image.path);
    setState(() {
      _image = image;
      _images.add(image.path);
    });
  }

  //https://medium.com/fabcoding/adding-an-image-picker-in-a-flutter-app-pick-images-using-camera-and-gallery-photos-7f016365d856
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future showDateSelection(mydate) async {

    FocusManager.instance.primaryFocus.unfocus();

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        DateFormat dateFormat = DateFormat("dd/MM/yyyy");
        mydate.text = dateFormat.format(picked);
      });
  }

  drugDialog(BuildContext context, Drug drug1) {
    var drugRoles = new List<String>.from(
        ApplicationLocalizations.of(context).translate("drug_roles"));
    var doseUnits = new List<String>.from(
        ApplicationLocalizations.of(context).translate("dose_units"));
    var doseRoutes = new List<String>.from(
        ApplicationLocalizations.of(context).translate("dose_routes"));
    var doseEach = new List<String>.from(
        ApplicationLocalizations.of(context).translate("dose_each"));
    var doseSchedules = new List<String>.from(
        ApplicationLocalizations.of(context).translate("dose_schedules"));
    var actionList = new List<String>.from(
        ApplicationLocalizations.of(context).translate("action_list"));
    var countries = new List<String>.from(
        ApplicationLocalizations.of(context).translate("countries"));

    TextEditingController startDate = new TextEditingController();
    TextEditingController action_taken_date = new TextEditingController();
    TextEditingController name = new TextEditingController();
    TextEditingController dose = new TextEditingController();
    TextEditingController each = new TextEditingController();
    TextEditingController indication = new TextEditingController();
    TextEditingController manufacturer = new TextEditingController();
    String selectedRole, selectedDoseUnit, selectedDoseRoute, selectedFrequency, selectedOrigin, selectedSchedule, selectedActionTaken;

    if (drug1 != null) {
      setState(() {
        _drug = drug1;
        name.text = drug1.name;
        selectedRole = drug1.role;
        dose.text = drug1.dose;
        selectedDoseUnit = drug1.dose_unit;
        selectedDoseRoute = drug1.dose_route;
        selectedFrequency = drug1.frequency;
        each.text = drug1.each;
        selectedSchedule = drug1.schedule;
        startDate.text = drug1.start_date;
        selectedActionTaken = drug1.action_taken;
        action_taken_date.text = drug1.action_taken_date;
        indication.text = drug1.indication;
        manufacturer.text = drug1.manufacturer;
        selectedOrigin = drug1.origin;
      });
    }


    showDialog(
        context: context,
        builder: (BuildContext context) {
          // set up the buttons
          Widget cancelButton = RaisedButton(
            child:
                Text(ApplicationLocalizations.of(context).translate("cancel")),
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.blue,
          );
          Widget continueButton = RaisedButton(
            child: Text(ApplicationLocalizations.of(context).translate("add")),
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
              var uuid = Uuid();
              var id = uuid.v1();
              _drug.id = id;
              log("Drug: " + _drug.toJson().toString());
              sharedPref.save(_source, _drugList);
              setState(() {
                _drugList.add(_drug);
              });
              Navigator.of(context).pop();
            },
            textColor: Colors.blue,
          );

          if (drug1 != null) {
            continueButton = RaisedButton(
              child:
              Text(ApplicationLocalizations.of(context).translate("edit")),
              onPressed: () {
                log(_drug.toJson().toString());
                int i = 0;
                for (Drug list in _drugList.list) {
                  if (list.id == drug1.id) {
                    _drugList.remove(i);
                    break;
                  }
                  i++;
                }

                _drugList.add(_drug);
                log(_drugList.toJson().toString());
                sharedPref.save(_source, _drugList);

                Navigator.of(context).pop();
              },
              textColor: Colors.blue,
            );
          }

          return AlertDialog(
            scrollable: true,
            insetPadding: EdgeInsets.all(5),
            content: SingleChildScrollView(
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Form(
                    key: _key,
                    autovalidateMode : AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                            labelText: ApplicationLocalizations.of(context)
                                .translate("drug_name")
                                .toString(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          onChanged: (value) => setState(() {
                            _drug.name = value;
                          }),
                          validator: (value) {
                            if (value.isEmpty) {
                              return ApplicationLocalizations.of(context)
                                  .translate("error_mandatory_drug_name").toString();
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelText: ApplicationLocalizations.of(context)
                                .translate("drug_role")
                                .toString(),
                          ),
                          items: drugRoles.map((e) {
                            return DropdownMenuItem<String>(
                              child: Text(e),
                              value: e,
                            );
                          }).toList(),
                          validator: (String value) {
                            if (value == null || value.isEmpty) {
                              return ApplicationLocalizations.of(context)
                                  .translate("error_mandatory_drug_role").toString();
                            }
                            return null;
                          },
                          value: selectedRole,
                          onChanged: (value) => setState(() {
                            _drug.role = value;
                          }),
                          onTap: (){
                            FocusManager.instance.primaryFocus.unfocus();
                          },
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: dose,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText:
                                      ApplicationLocalizations.of(context)
                                          .translate("dose")
                                          .toString(),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                onChanged: (value) => setState(() {
                                  _drug.dose = value;
                                }),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Expanded(
                                child: DropdownButtonFormField(
                              isExpanded: false,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: ApplicationLocalizations.of(context)
                                    .translate("dose_unit")
                                    .toString(),
                              ),
                              items: doseUnits.map((e) {
                                return DropdownMenuItem<String>(
                                  child: Text(e),
                                  value: e,
                                );
                              }).toList(),
                                  onTap: (){
                                    FocusManager.instance.primaryFocus.unfocus();
                                  },
                              value: selectedDoseUnit,
                              onChanged: (value) => setState(() {
                                _drug.dose_unit = value;
                              }),

                            )),
                            SizedBox(
                              width: 5.0,
                            ),
                            Expanded(
                                child: DropdownButtonFormField(
                              isExpanded: false,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: ApplicationLocalizations.of(context)
                                    .translate("dose_route")
                                    .toString(),
                              ),
                              items: doseRoutes.map((e) {
                                return DropdownMenuItem<String>(
                                  child: Text(e),
                                  value: e,
                                );
                              }).toList(),
                              value: selectedDoseRoute,
                              onChanged: (value) => setState(() {
                                _drug.dose_route = value;
                              }),
                                  onTap: (){
                                    FocusManager.instance.primaryFocus.unfocus();
                                  },
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: DropdownButtonFormField(
                              isExpanded: false,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: ApplicationLocalizations.of(context)
                                    .translate("frequency")
                                    .toString(),
                              ),
                              items: doseEach.map((e) {
                                return DropdownMenuItem<String>(
                                  child: Text(e),
                                  value: e,
                                );
                              }).toList(),
                              value: selectedFrequency,
                              onChanged: (value) => setState(() {
                                _drug.frequency = value;
                              }),
                                  onTap: (){
                                    FocusManager.instance.primaryFocus.unfocus();
                                  },
                            )),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              width: 75,
                              child: TextField(
                                controller: each,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: ApplicationLocalizations.of(context).translate("each").toString(),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                onChanged: (value) => setState(() {
                                  _drug.each = value;
                                }),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Expanded(
                                child: DropdownButtonFormField(
                              isExpanded: false,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: ApplicationLocalizations.of(context)
                                    .translate("dose_schedule")
                                    .toString(),
                              ),
                              items: doseSchedules.map((e) {
                                return DropdownMenuItem<String>(
                                  child: Text(e),
                                  value: e,
                                );
                              }).toList(),
                              value: selectedSchedule,
                              onChanged: (value) => setState(() {
                                _drug.schedule = value;
                              }),
                                  onTap: (){
                                    FocusManager.instance.primaryFocus.unfocus();
                                  },
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        DateTimeField(
                          controller: startDate,
                          format: dateFormat,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100));
                          },
                          onChanged: (date) => setState(() {
                            //reaction.onset_date = dateFormat.format(date).toString();
                            _drug.start_date =
                                dateFormat.format(date).toString();
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today),
                            labelText: ApplicationLocalizations.of(context)
                                .translate("start_date")
                                .toString(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  labelText:
                                      ApplicationLocalizations.of(context)
                                          .translate("action_taken")
                                          .toString(),
                                ),
                                items: actionList.map((e) {
                                  return DropdownMenuItem<String>(
                                    child: Text(e),
                                    value: e,
                                  );
                                }).toList(),
                                value: selectedActionTaken,
                                onChanged: (value) => setState(() {
                                  _drug.action_taken = value;
                                }),
                                onTap: (){
                                  FocusManager.instance.primaryFocus.unfocus();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: DateTimeField(
                                controller: action_taken_date,
                                format: dateFormat,
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                },
                                onChanged: (date) => setState(() {
                                  //reaction.onset_date = dateFormat.format(date).toString();
                                  _drug.action_taken_date =
                                      dateFormat.format(date).toString();
                                }),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_today),
                                  labelText:
                                      ApplicationLocalizations.of(context)
                                          .translate("action_on")
                                          .toString(),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          controller: indication,
                          decoration: InputDecoration(
                            labelText: ApplicationLocalizations.of(context)
                                .translate("indication")
                                .toString(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          onChanged: (value) => setState(() {
                            _drug.indication = value;
                          }),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          controller: manufacturer,
                          decoration: InputDecoration(
                            labelText: ApplicationLocalizations.of(context)
                                .translate("manufacturer")
                                .toString(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          onChanged: (value) => setState(() {
                            _drug.manufacturer = value;
                          }),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        DropdownButtonFormField(
                          items: countries.map((e) {
                            return DropdownMenuItem<String>(
                              child: Text(e),
                              value: e,
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.place),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelText: ApplicationLocalizations.of(context)
                                .translate("origin")
                                .toString(),
                          ),
                          value: selectedOrigin,
                          onChanged: (value) => setState(() {
                            _drug.origin = value;
                          }),
                          onTap: (){
                            FocusManager.instance.primaryFocus.unfocus();
                          },
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              cancelButton,
                              SizedBox(width: 5),
                              continueButton,
                            ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
