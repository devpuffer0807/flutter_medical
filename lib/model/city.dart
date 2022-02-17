import 'package:flutter/cupertino.dart';
import 'package:iraqpvc/application_localizations.dart';

class City {
  //--- Name Of City
  final String name;

  City({this.name});

  static List<String> listCities(BuildContext context) {
    var cities =
        ApplicationLocalizations.of(context).translate("cities") as List;
    return cities;
  }
}
