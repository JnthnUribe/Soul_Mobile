import 'dart:async';

import 'package:darkness_dungeon/util/localization/my_localizations.dart';
import 'package:flutter/material.dart';

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'es'; // Solo español

  @override
  Future<MyLocalizations> load(Locale locale) async {
    MyLocalizations localizations = new MyLocalizations(locale);
    await localizations.load();
    print("Load ${locale.languageCode}");
    return localizations;
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;

  Locale resolution(Locale? locale, Iterable<Locale> supportedLocales) {
    // Siempre devolver español, sin importar el idioma del dispositivo
    return const Locale('es', 'ES');
  }

  static List<Locale> supportedLocales() {
    // Solo español disponible
    return [const Locale('es', 'ES')];
  }
}
