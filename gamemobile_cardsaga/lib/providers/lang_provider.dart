import 'package:flutter/material.dart';

class LangProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
}
