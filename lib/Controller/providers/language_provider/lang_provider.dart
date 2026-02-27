import 'package:flutter/material.dart';

class LangProvider extends ChangeNotifier {
  static const List<Map<String, dynamic>> languages = [
    {'name': "English", 'locale': 'en'},
    {'name': "Hindi", 'locale': 'hi'},
  ];

  Locale selectedLocale = Locale('en');

  void changeLanguage(String lang) {
    print(lang);
    selectedLocale = Locale(lang);
    notifyListeners();
  }
}
