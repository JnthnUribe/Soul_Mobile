import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/game.dart';
import 'package:darkness_dungeon/util/dialogs.dart';
import 'package:flutter/material.dart';

class GameController extends GameComponent {
  bool showGameOver = false;
  @override
  void update(double dt) {
    if (checkInterval('gameOver', 100, dt)) {
      if (gameRef.player != null && gameRef.player?.isDead == true) {
        if (!showGameOver) {
          showGameOver = true;
          _showDialogGameOver();
        }
      }
    }
    super.update(dt);
  }

  void _showDialogGameOver() {
    showGameOver = true;
    Dialogs.showGameOver(
      context,
      () {
        print('🔄 Reiniciando desde Game Over...');
        
        // Marcar que estamos reiniciando ANTES de cerrar
        Game.isRestarting = true;
        
        // Cerrar el diálogo primero
        Navigator.of(context).pop();
        
        // Esperar más tiempo para que dispose() se complete ANTES de crear el nuevo juego
        Future.delayed(Duration(milliseconds: 500), () {
          print('⏭️ Navegando a nuevo juego...');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Game()),
            (Route<dynamic> route) => false,
          );
        });
      },
    );
  }
}
