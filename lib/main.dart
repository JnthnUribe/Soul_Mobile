import 'package:darkness_dungeon/menu.dart';
import 'package:darkness_dungeon/util/localization/my_localizations_delegate.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'util/sounds.dart';

double tileSize = 32;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }
  await Sounds.initialize();
  MyLocalizationsDelegate myLocation = const MyLocalizationsDelegate();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Normal',
      ),
      home: Menu(),
      // Forzar español en toda la aplicación (Android & iOS)
      locale: const Locale('es', 'ES'),
      supportedLocales: [const Locale('es', 'ES')], // Solo español
      localizationsDelegates: [
        myLocation,
        DefaultCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Siempre devolver español, sin importar el idioma del dispositivo
        print('🌍 Forzando idioma a español');
        return const Locale('es', 'ES');
      },
    ),
  );
}
