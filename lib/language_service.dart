// language_service.dart
import 'package:flutter/material.dart';
//toggle feature
class LanguageService extends ChangeNotifier {
  bool _isEnglish = true;

  bool get isEnglish => _isEnglish;

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }
}