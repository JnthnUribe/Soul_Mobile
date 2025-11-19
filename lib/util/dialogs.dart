import 'package:darkness_dungeon/game.dart';
import 'package:darkness_dungeon/menu.dart';
import 'package:darkness_dungeon/shop/shop_screen.dart';
import 'package:darkness_dungeon/util/localization/strings_location.dart';
import 'package:flutter/material.dart';

class Dialogs {
  static void showGameOver(BuildContext context, VoidCallback playAgain) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/game_over.png',
                height: 100,
              ),
              SizedBox(height: 30.0),
              
              // Botón Volver a Jugar
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: playAgain,
                  child: Text(
                    getString('play_again_cap'),
                    style: TextStyle(
                      fontFamily: 'Normal',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 15.0),
              
              // Botón Menú Principal
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Menu()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text(
                    'Menú Principal',
                    style: TextStyle(
                      fontFamily: 'Normal',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  static void showPauseMenu(
    BuildContext context, {
    required VoidCallback onResume,
    required VoidCallback onRestart,
    required VoidCallback onMainMenu,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurple, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Título
                  Text(
                    'PAUSA',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Normal',
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 20.0),
                  
                  // Botón Reanudar
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onResume();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Reanudar',
                            style: TextStyle(
                              fontFamily: 'Normal',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10.0),
                  
                  // Botón Tienda
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.black,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShopScreen()),
                        );
                        onResume();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Tienda',
                            style: TextStyle(
                              fontFamily: 'Normal',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10.0),
                  
                  // Botón Reiniciar
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        print('🔄 Reiniciando desde menú de pausa...');
                        
                        // Marcar que estamos reiniciando ANTES de cerrar
                        Game.isRestarting = true;
                        
                        // Guardar el navigator ANTES de cerrar
                        final navigator = Navigator.of(context);
                        
                        // Cerrar el menú de pausa
                        navigator.pop();
                        
                        // Esperar para que todo se limpie
                        Future.delayed(Duration(milliseconds: 500), () {
                          print('⏭️ Navegando a nuevo juego...');
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => Game()),
                            (Route<dynamic> route) => false,
                          );
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Reiniciar',
                            style: TextStyle(
                              fontFamily: 'Normal',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10.0),
                  
                  // Botón Menú Principal
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Menu()),
                          (Route<dynamic> route) => false,
                        );
                        onMainMenu();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Menú Principal',
                            style: TextStyle(
                              fontFamily: 'Normal',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showCongratulations(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  getString('congratulations'),
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Normal',
                      fontSize: 30.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Text(
                    getString('thanks'),
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Normal',
                        fontSize: 18.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 118, 82, 78)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                  child: Text("OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Normal',
                          fontSize: 17.0)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Menu()),
                      (Route<dynamic> route) => false,
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static void showVictoryDialog(
      BuildContext context, VoidCallback onNextLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Título de Victoria
              Text(
                "¡VICTORIA!",
                style: TextStyle(
                  color: Colors.amber,
                  fontFamily: 'Normal',
                  fontSize: 40.0,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),

              // Botón Siguiente Nivel
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNextLevel();
                  },
                  child: Text(
                    'Siguiente Nivel',
                    style: TextStyle(
                      fontFamily: 'Normal',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15.0),

              // Botón Menú Principal
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Menu()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text(
                    'Menú Principal',
                    style: TextStyle(
                      fontFamily: 'Normal',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
