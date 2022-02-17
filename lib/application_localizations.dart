// check the help source https://www.thirdrocktechkno.com/blog/how-to-implement-localization-in-flutter
// https://resocoder.com/2019/06/01/flutter-localization-the-easy-way-internationalization-with-json/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApplicationLocalizations {

  final Locale appLocale;

  ApplicationLocalizations(this.appLocale);
  static const LocalizationsDelegate<ApplicationLocalizations> delegate =
      _ApplicationLocalizationsDelegate();

  static ApplicationLocalizations of(BuildContext context) {
    return Localizations.of<ApplicationLocalizations>(
        context, ApplicationLocalizations);
  }

  Map<String, dynamic> _localizedStrings;

  Future<bool> load() async {
    // Load JSON file from the "language" folder
    String jsonString = await rootBundle
        .loadString('assets/lang/${appLocale.languageCode}.json');
    _localizedStrings = jsonDecode(jsonString);

    /*
    _localizedStrings = jsonLanguageMap.map((key, value) {
      return MapEntry(key, value);
    });
    */
    return true;
  }

  // called from every widget which needs a localized text
  dynamic translate(String jsonkey) {
    return _localizedStrings[jsonkey];
  }
}

class _ApplicationLocalizationsDelegate
    extends LocalizationsDelegate<ApplicationLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _ApplicationLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<ApplicationLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    ApplicationLocalizations localizations =
        new ApplicationLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_ApplicationLocalizationsDelegate old) => false;
}
