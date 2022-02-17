import 'dart:developer';
import 'dart:io';

import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:iraqpvc/application_localizations.dart';
import 'package:iraqpvc/model/reaction.dart';
import 'package:iraqpvc/model/reactions.dart';
import 'package:iraqpvc/util/sharedPref.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:convert';

// ignore: must_be_immutable
class ReactionForm extends StatefulWidget {
  final TabController tabController;
  final ValueChanged<int> parentAction;

  ReactionForm({this.tabController, this.parentAction});

  @override
  _ReactionFormState createState() => _ReactionFormState();
}

class _ReactionFormState extends State<ReactionForm> {
  SharedPref sharedPref = SharedPref();
  Reactions reactionList = Reactions();
  Reaction reaction = Reaction();
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  List<String> _imageList = new List<String>();

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  var _source = "Reactions_en";

  loadSharedPrefs() async {
    try {
      if (ApplicationLocalizations.of(context).appLocale.languageCode == 'ar')
        _source = "Reactions_ar";

      reactionList = Reactions.fromJson(await sharedPref.read(_source));
      log("loadSharedPrefs: " + reactionList.toJson().toString());
      setState(() {
        reactionList.list.length;
      });
    } catch (Exception) {
      log("No Reactions found");
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

  List<String> _selectedReactions = new List<String>();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
          Image.asset("assets/images/reaction.jpg"),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
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
                            reaction = new Reaction();
                          });
                          reactionDialog(context, null);
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
                          //sharedPref.save(_source, {});
                          log("selected items: " +
                              _selectedReactions.length.toString());

                          if (_selectedReactions.length == 0) {
                            return false;
                          }
                          setState(() {
                            for (String id in _selectedReactions) {
                              reactionList.list
                                  .removeWhere((element) => element.id == id);
                            }
                          });
                          sharedPref.save(_source, reactionList);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.4, // fixed height
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: ListView.builder(
                        itemCount: reactionList.list.length,
                        itemBuilder: (context, index) {
                          var _reactionId = reactionList.list[index].id;
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
                                        value: _selectedReactions
                                            .contains(_reactionId),
                                        onChanged: (value) {
                                          setState(() {
                                            if (_selectedReactions
                                                .contains(_reactionId)) {
                                              _selectedReactions
                                                  .remove(_reactionId);
                                            } else {
                                              _selectedReactions
                                                  .add(_reactionId);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      child: ListTile(
                                          title: Text(
                                              reactionList.list[index].name),
                                          subtitle: (reactionList
                                                      .list[index].outcome !=
                                                  null)
                                              ? Text(reactionList
                                                  .list[index].outcome)
                                              : null,
                                          onTap: () {
                                            log("you clicked on: " +
                                                reactionList.list[index].name);
                                            reactionDialog(context,
                                                reactionList.list[index]);
                                            //_showSnackBar(context, _allNews[index]);
                                          }),
                                    ),
                                  ]));
                        },
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RaisedButton.icon(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      widget.tabController.animateTo(1);
                      widget.parentAction(1);
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
                      if (reactionList.list.length == 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              title: Text(ApplicationLocalizations.of(context)
                                  .translate("error_alert_title")
                                  .toString()),
                              content: Text(ApplicationLocalizations.of(context)
                                  .translate("error_mandatory_reaction")
                                  .toString()),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new FlatButton(
                                  child: Text(
                                      ApplicationLocalizations.of(context)
                                          .translate("close")
                                          .toString()),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        widget.parentAction(3);
                        widget.tabController.animateTo(3);
                      }
                    },
                    label: Text(ApplicationLocalizations.of(context)
                        .translate("next")
                        .toString()),
                    color: Colors.lightGreen,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ))
              ]),
        ])));
  }

  File _image;

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    reactionList.addImages(image.path);
    sharedPref.save("Reactions", reactionList);
    log("image path " + image.path);
    setState(() {
      _image = image;
      _imageList.add(image.path);
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    reactionList.addImages(image.path);
    sharedPref.save("Reactions", reactionList);

    log("image gallery path " + image.path);
    log("reactionList " + reactionList.toJson().toString());
    setState(() {
      _image = image;
      _imageList.add(image.path);
    });
  }

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

  void reactionDialog(BuildContext context, Reaction reaction1) {
    var outcomes = new List<String>.from(
        ApplicationLocalizations.of(context).translate("outcomes"));
    var seriousness = new List<String>.from(
        ApplicationLocalizations.of(context).translate("seriousness"));
    var durations = new List<String>.from(
        ApplicationLocalizations.of(context).translate("durations"));

    List<String> checkList = new List<String>();
    List<String> real_checkList = [];
    var temp = [];
    if( reaction != null ){
      if (reaction.seriousness != null) {
        temp = reaction.seriousness
            .substring(1, reaction.seriousness.length - 1)
            .split(", ");
        checkList.clear();
        real_checkList.clear();
        for (int i = 0; i < temp.length; i++) {
          checkList.add(temp[i]);
          real_checkList.add(temp[i]);
        }
      }
    }else if(reaction1 != null){
      if(reaction1.seriousness != null){
        temp = reaction1.seriousness
            .substring(1, reaction1.seriousness.length - 1)
            .split(", ");
        checkList.clear();
        real_checkList.clear();
        for (int i = 0; i < temp.length; i++) {
          checkList.add(temp[i]);
          real_checkList.add(temp[i]);
        }
      }
    }

    TextEditingController onsetDate = new TextEditingController();
    TextEditingController onEndDate = new TextEditingController();
    TextEditingController name = new TextEditingController();
    TextEditingController duration = new TextEditingController();
    String selectedOutcome, selectedTime, uniqId, selectedSeriousness;

    if (reaction1 != null) {
      setState(() {
        reaction = reaction1;
        uniqId = reaction1.id;
        onsetDate.text = reaction1.onset_date;
        onEndDate.text = reaction1.end_date;
        name.text = reaction1.name;
        duration.text = reaction1.duration;
        selectedSeriousness = reaction1.seriousness;
        //--------------
        selectedOutcome = reaction1.outcome;
        selectedTime = reaction1.duration_time;
      });
    }

    showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          // set up the           s
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
              reaction.id = id;
              log(reaction.toJson().toString());
              setState(() {
                reactionList.add(reaction);
                reaction = null;
              });
              sharedPref.save(_source, reactionList);
              Navigator.of(context).pop();
            },
            textColor: Colors.blue,
          );

          if (reaction1 != null) {
            continueButton = RaisedButton(
              child:
                  Text(ApplicationLocalizations.of(context).translate("edit")),
              onPressed: () {
                log(reaction.toJson().toString());
                int i = 0;
                for (Reaction list in reactionList.list) {
                  if (list.id == reaction1.id) {
                    reactionList.remove(i);
                    break;
                  }
                  i++;
                }

                reactionList.add(reaction);
                log(reactionList.toJson().toString());
                sharedPref.save(_source, reactionList);
                Navigator.of(context).pop();
              },
              textColor: Colors.blue,
            );
          }

          return StatefulBuilder(builder: (context, setStats) {
            setStats((){});
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
                                  .translate("title_adverse_reaction")
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
                            validator: (value) {
                              if (value.isEmpty) {
                                return ApplicationLocalizations.of(context)
                                    .translate("title_adverse_reaction")
                                    .toString();
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                reaction.name = value;
                              });
                            },
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          DateTimeField(
                            controller: onsetDate,
                            format: dateFormat,
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                            },
                            onChanged: (date) => setState(() {
                              reaction.onset_date =
                                  dateFormat.format(date).toString();
                            }),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today),
                              labelText: ApplicationLocalizations.of(context)
                                  .translate("onset_date")
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
                          ButtonTheme(
                              minWidth: double.infinity,
                              height: 60.0,
                              child: OutlineButton(
                                child: Text(
                                    real_checkList.join(",").length == 0
                                        ? ApplicationLocalizations.of(context).translate("seriousness_level").toString()
                                        : real_checkList.join(",").substring(1),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        overflow: TextOverflow.ellipsis)),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                                onPressed: () {
                                  setStats(() {
                                    checkList.clear();
                                    checkList.insertAll(0, real_checkList);

                                  });
                                  print("hello" + checkList.length.toString());
                                  setState(() {

                                  });
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        false, // user must tap button!
                                    builder: (BuildContext context) {
                                      return Dialog(
                                          elevation: 0.0,
                                          backgroundColor: Colors.transparent,
                                          child: StatefulBuilder(
                                            builder: (context, setStates) {
                                              return Container(
                                                color: Colors.yellow[100],
                                                padding: EdgeInsets.all(20),
                                                height: 600,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    ListView.builder(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        itemCount:
                                                            seriousness.length,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return InkWell(
                                                            onTap: () {
                                                              setStates(() {
                                                                if (checkList.contains(
                                                                    seriousness[
                                                                        index])) {
                                                                  checkList.removeWhere((item) =>
                                                                      item ==
                                                                      seriousness[
                                                                          index]);
                                                                } else {
                                                                  checkList.add(seriousness[index]);
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border(
                                                                  bottom: BorderSide(
                                                                      width:
                                                                          1.0,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 15,
                                                                      bottom:
                                                                          15),
                                                              width: double
                                                                  .infinity,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color: Colors
                                                                                .blue,
                                                                            width:
                                                                                2),
                                                                        color: checkList.contains(seriousness[index])
                                                                            ? Colors.blue
                                                                            : Colors.transparent),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              2.0),
                                                                      child: checkList
                                                                              .contains(seriousness[index])
                                                                          ? Icon(
                                                                              Icons.check,
                                                                              size: 15.0,
                                                                              color: Colors.white,
                                                                            )
                                                                          : Icon(
                                                                              Icons.check,
                                                                              size: 15.0,
                                                                              color: Colors.blue,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Text(
                                                                    seriousness[
                                                                        index],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                                  ))
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                    Row(
                                                      children: [
                                                        RaisedButton(
                                                          child: Text(
                                                              ApplicationLocalizations
                                                                      .of(
                                                                          context)
                                                                  .translate(
                                                                      "cancel")),
                                                          onPressed: () {
                                                            setStats(() {
                                                              checkList.clear();
                                                              checkList.insertAll(
                                                                  0,
                                                                  real_checkList);
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          textColor:
                                                              Colors.blue,
                                                        ),
                                                        RaisedButton(
                                                          child: Text(
                                                              ApplicationLocalizations
                                                                      .of(
                                                                          context)
                                                                  .translate(
                                                                      "add")),
                                                          onPressed: () {
                                                            setStats(() {
                                                              real_checkList
                                                                  .clear();
                                                              real_checkList
                                                                  .insertAll(0,
                                                                      checkList);
                                                            });
                                                            setState(() {
                                                              reaction.seriousness =
                                                                  real_checkList
                                                                      .toString();
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          textColor:
                                                              Colors.blue,
                                                        )
                                                      ],
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ));
                                    },
                                  );
                                },
                              )),
                          // MultiSelectDialogField(
                          //   title: Text(""),
                          //   height: 400.0,
                          //   backgroundColor: Colors.yellow[100],
                          //   items: seriousness
                          //       .map((e) => MultiSelectItem(e, e))
                          //       .toList(),
                          //   listType: MultiSelectListType.LIST,
                          //   buttonText: Text("Seriousness Level"),
                          //   // initialValue: selectedSeriousness.split(","),
                          //   onConfirm: (values) {
                          //     //_selectedAnimals = values;
                          //     setState(() {
                          //       reaction.seriousness = values.toString();
                          //     });
                          //   },
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(5),
                          //     color: Colors.white,
                          //     boxShadow: [
                          //       BoxShadow(color: Colors.grey, spreadRadius: 1),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 15.0,
                          ),
                          DropdownButtonFormField(
                            items: outcomes.map((e) {
                              return DropdownMenuItem<String>(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
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
                                  .translate("outcome")
                                  .toString(),
                            ),
                            value: selectedOutcome,
                            onChanged: (value) {
                              setState(() {
                                reaction.outcome = value;
                              });
                            },
                            onTap: () {
                              FocusManager.instance.primaryFocus.unfocus();
                            },
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: duration,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText:
                                        ApplicationLocalizations.of(context)
                                            .translate("duration")
                                            .toString(),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      reaction.duration = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: DropdownButtonFormField(
                                  //value: selectedTime,
                                  items: durations.map((e) {
                                    return DropdownMenuItem<String>(
                                      child: Text(e),
                                      value: e,
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    labelText:
                                        ApplicationLocalizations.of(context)
                                            .translate("time")
                                            .toString(),
                                  ),
                                  value: selectedTime,
                                  onChanged: (value) {
                                    setState(() {
                                      reaction.duration_time = value;
                                    });
                                  },
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        .unfocus();
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          DateTimeField(
                            controller: onEndDate,
                            format: dateFormat,
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                            },
                            onChanged: (date) => setState(() {
                              reaction.end_date =
                                  dateFormat.format(date).toString();
                            }),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today),
                              labelText: ApplicationLocalizations.of(context)
                                  .translate("end_date")
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
        });
  }
}
