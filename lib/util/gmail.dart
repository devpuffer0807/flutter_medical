import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iraqpvc/model/drugs.dart';
import 'package:iraqpvc/model/patient.dart';
import 'package:iraqpvc/model/profile.dart';
import 'package:iraqpvc/model/reactions.dart';
import 'package:iraqpvc/util/sharedPref.dart';
import 'package:mailer2/mailer.dart';

import '../application_localizations.dart';

class Gmail{
  SharedPref sharedPref = SharedPref();
  Profile profile = Profile();
  DrugList _drugList = new DrugList();
  Patient patient = Patient();
  Reactions reactionList = Reactions();
  var _PatientSource = "Patient_en";

  Future<bool> send2(BuildContext context, String languageCode) async {

    String email = await rootBundle.loadString("assets/report/en.html");
    if (languageCode == 'ar') {
      email = await rootBundle.loadString("assets/report/ar.html");
      _PatientSource = "Patient_ar";
    }
    var profileKey  = await sharedPref.read("profile_"+languageCode);
    profile = Profile.fromJson(profileKey);
    patient = Patient.fromJson(await sharedPref.read("Patient_"+languageCode));
    reactionList = Reactions.fromJson(await sharedPref.read("Reactions_"+languageCode));
    _drugList = DrugList.fromJson(await sharedPref.read("DrugList_"+languageCode));


    // Create our mail/envelope.
    var envelope = new Envelope()
      //..from = (profile.email != null || profile.email.isNotEmpty || profile.email.length > 0) ? profile.email : 'iraqpvc@gmail.com'
     ..from = defaultemail()
      //..from =  'iraqpvc@gmail.com'
      ..recipients.add('iraqphvc@gmail.com')
      //..recipients.add('mbasil1980@gmail.com') //mbasel80@gmail.com
      //..recipients.add('umaster.in@gmail.com') //mbasel80@gmail.com
      ..subject = profile.city + " ADRs report";


    email = email.replaceAll("[NAME]", profile.name)
            .replaceAll("[PHONE]", profile.phone)
            .replaceAll("[EMAIL]", checkfornull(profile.email))
            .replaceAll("[CITY]", profile.city)
            .replaceAll("[ORG]", checkfornull(profile.org))
            .replaceAll("[PROFESSION]", profile.profession);

    email = email.replaceAll("[PATIENT_NAME]", patient.name)
        .replaceAll("[PATIENT_GENDER]", checkfornull(patient.gender))
        .replaceAll("[PATIENT_AGE]", patient.age)
        .replaceAll("[PATIENT_AGEOPTION]", patient.age_option)
        .replaceAll("[PATIENT_HEIGHT]", checkfornull(patient.height))
        .replaceAll("[PATIENT_WEIGHT]", checkfornull(patient.weight))
        .replaceAll("[PATIENT_MEDICAL_NOTES]", checkfornull(patient.medical_notes));

  String reactionHtmlTemplate = '''<table style="border-color: #000000;" border="1" cellspacing="0" cellpadding="5">
      <tbody>
    <tr>
    <td width="187">
    <p>*Adverse reaction</p>
    </td>
    <td colspan="2" width="452">
    <p style="color:red;">[REACTION_NAME]</p>
    </td>
    </tr>
    <tr>
    <td width="187">
    <p>Onset date</p>
    </td>
    <td colspan="2" width="452">
    <p style="color:red;">&nbsp;[REACTION_ONSETDATE]</p>
    </td>
    </tr>
    
    <tr>
      <td width="187">
        <p>Seriousness Level</p>
      </td>
      <td colspan="2" width="452">
        <p style="color:red;">&nbsp;[REACTION_SERIOUSNESS_LEVEL]</p>
      </td>
    </tr> 
    
    <tr>
    <td width="187">
    <p>Outcome</p>
    </td>
    <td colspan="2" width="452">
    <p style="color:red;">&nbsp;[REACTION_OUTCOME]</p>
    </td>
    </tr>
    <tr>
    <td width="187">
    <p>Duration</p>
    </td>
    <td width="151">
    <p style="color:red;">&nbsp;[REACTION_DURATION]</p>
    </td>
    <td width="300">
    <p style="color:red;">Time [REACTION_TIME]</p>
    </td>    
    </tr>
    <tr>
    <td width="187">
    <p>End Date</p>
    </td>
    <td colspan="2" width="452">
    <p style="color:red;">&nbsp;[REACTION_ENDDATE]</p>
    </td>
    </tr>
    </tbody>
    </table><br><br>
    ''';
    String reactionsHtml = '';
    String tempReactionHtmlTemplate = '';
    reactionList.list.forEach((reaction) {
      log("Reaction1: " +reaction.toJson().toString());
      tempReactionHtmlTemplate = reactionHtmlTemplate.replaceAll("[REACTION_NAME]", reaction.name)
          .replaceAll("[REACTION_ONSETDATE]", checkfornull(reaction.onset_date))
          .replaceAll("[REACTION_OUTCOME]", checkfornull(reaction.outcome))
          .replaceAll("[REACTION_DURATION]", checkfornull(reaction.duration))
          .replaceAll("[REACTION_TIME]", checkfornull(reaction.duration_time))
          .replaceAll("[REACTION_ENDDATE]", checkfornull(reaction.end_date))
          .replaceAll("[REACTION_SERIOUSNESS_LEVEL]", checkfornull(reaction.seriousness));

      reactionsHtml += tempReactionHtmlTemplate;
    });

    String drugsHtmlTemplate = '''    
    <table style="border-color: #000000;" border="1" cellspacing="0" cellpadding="5">
    <tbody>
    <tr>
    <td colspan="2" width="197">
    <p>*Drug name</p>
    </td>
    <td colspan="7" width="441">
    <p style="color:red;">[DRUG_NAME]</p>
    </td>
    </tr>
    <tr>
    <td colspan="2" width="197">
    <p>*Drug role</p>
    </td>
    <td colspan="7" width="441">
    <p style="color:red;">[DRUG_ROLE]</p>
    </td>
    </tr>
    <tr>
    <td width="107">
    <p>Dose</p>
    </td>
    <td width="91">
    <p style="color:red;">[DRUG_DOSE]</p>
    </td>
    <td colspan="2" width="111">
    <p>Unit</p>
    </td>
    <td colspan="2" width="110">
    <p style="color:red;">[DRUG_UNIT]</p>
    </td>
    <td colspan="2" width="111">
    <p>Route</p>
    </td>
    <td width="109">
    <p style="color:red;">[DRUG_ROUTE]</p>
    </td>
    </tr>
    <tr>
    <td width="107">
    <p>Frequency</p>
    </td>
    <td width="91">
    <p style="color:red;">[DRUG_FREQUENCY]</p>
    </td>
    <td width="110">
    <p>Each</p>
    </td>
    <td colspan="3" width="110">
    <p style="color:red;">[DRUG_EACH]</p>
    </td>
    <td width="110">
    <p>time</p>
    </td>
    <td colspan="2" width="110">
    <p style="color:red;">[DRUG_SCHEDULE]</p>
    </td>
    </tr>
    <tr>
    <td colspan="2" width="197">
    <p>Date started</p>
    </td>
    <td colspan="7" width="441">
    <p style="color:red;">[DRUG_START_DATE]</p>
    </td>
    </tr>
    <tr>
    <td colspan="2" width="197">
    <p>Action taken</p>
    </td>
    <td colspan="3" width="197">
    <p style="color:red;">[DRUG_ACTION_TAKEN]</p>
    </td>
    <td colspan="4" width="244">
    <p style="color:red;">On [DRUG_ACTION_TAKEN_DATE]</p>
    </td>
    </tr>
    <tr>
    <td colspan="2" width="197">
    <p>Indication</p>
    </td>
    <td colspan="7" width="441">
    <p style="color:red;">[DRUG_INDICATION]</p>
    </td>
    </tr>
    <tr>
    <td colspan="2" width="197">
    <p><strong>Manufacturer + Batch no.</strong></p>
    </td>
    <td colspan="7" width="441">
    <p style="color:red;">[DRUG_MANUFACTURER]</p>
    </td>
    </tr>
    <tr>
    <td colspan="2" width="197">
    <p>Origin country</p>
    </td>
    <td colspan="7" width="441">
    <p style="color:red;">[DRUG_ORIGIN]</p>
    </td>
    </tr>    
    </tbody>
    </table><br><br>''';


    String drugsHtml = '';
    String tempDrugsHtmlTemplate = '';
    _drugList.list.forEach((drug) {
      log("Drug1: " +drug.toJson().toString());
      tempDrugsHtmlTemplate = drugsHtmlTemplate.replaceAll("[DRUG_NAME]", drug.name)
          .replaceAll("[DRUG_ROLE]", drug.role )
          .replaceAll("[DRUG_DOSE]", checkfornull(drug.dose))
          .replaceAll("[DRUG_UNIT]", checkfornull(drug.dose_unit))
          .replaceAll("[DRUG_ROUTE]", checkfornull(drug.dose_route))
          .replaceAll("[DRUG_FREQUENCY]", checkfornull(drug.frequency))
          .replaceAll("[DRUG_EACH]", checkfornull(drug.each))
          .replaceAll("[DRUG_SCHEDULE]", checkfornull(drug.schedule))
          .replaceAll("[DRUG_START_DATE]", checkfornull(drug.start_date))
          .replaceAll("[DRUG_ACTION_TAKEN]", checkfornull(drug.action_taken))
          .replaceAll("[DRUG_ACTION_TAKEN_DATE]", checkfornull(drug.action_taken_date))
          .replaceAll("[DRUG_INDICATION]", checkfornull(drug.indication))
          .replaceAll("[DRUG_MANUFACTURER]", checkfornull(drug.manufacturer))
          .replaceAll("[DRUG_ORIGIN]", checkfornull(drug.origin));

      drugsHtml += tempDrugsHtmlTemplate;
    });


    email = email.replaceAll("[REACTION_LIST]", reactionsHtml)
        //.replaceAll("[REACTION_IMAGES]", reactions_images)
        .replaceAll("[DRUGS_LIST]", drugsHtml);
        //.replaceAll("[DRUGS_IMAGES]", drugs_images);

    //log("email: " + email);
    envelope.html =  email;

    var options = new GmailSmtpOptions()
      ..username = 'iraqpvc@gmail.com'
      ..password = '6d696e656d';

    var emailTransport = new SmtpTransport(options);

    emailTransport.send(envelope)
        .then((value) => complete(context))
        .catchError((e) => failed(context, e));
  }

  defaultemail(){
    if (profile.email != null ) {
      if(profile.email.isEmpty){
        return 'iraqpvc@gmail.com';
      }
      return profile.email.trim();
    } else {
      return 'iraqpvc@gmail.com';
    }
  }

  checkfornull(String str){
    if (str != null ) {
      if(str.trim().isEmpty){
        return "";
      }
      return str.trim();
    } else {
      return "";
    }
  }

  complete(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
         // title:  Text(ApplicationLocalizations.of(context).translate("dialog_alert").toString()),
          content: Text(ApplicationLocalizations.of(context)
              .translate("sending_email_success").toString()),
          actions: <Widget>[
            new FlatButton(
            child:  Text(ApplicationLocalizations.of(context)
            .translate("close").toString()),
              onPressed: () {
                Navigator.of(context).pop();
                //sharedPref.save(_PatientSource, {});
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  failed(BuildContext context, [e]) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:  Text(ApplicationLocalizations.of(context)
              .translate("error_alert_title").toString()),
          content: Text( ApplicationLocalizations.of(context)
                .translate("error_sending_email").toString() + " Error: " + e.toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child:  Text(ApplicationLocalizations.of(context)
            .translate("close").toString()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}