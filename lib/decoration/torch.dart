import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';
import 'package:flutter/material.dart';

class Torch extends GameDecoration {
  bool empty = false;
  Torch(Vector2 position, {this.empty = false})
      : super.withAnimation(
          animation: GameSpriteSheet.torch(),
          position: position,
          size: Vector2.all(tileSize),
        ) {
    // Optimizado: Reducir radio y desactivar pulso para mejor rendimiento
    setupLighting(
      LightingConfig(
        radius: width * 1.8,
        blurBorder: width * 0.7,
        pulseVariation: 0.0, // Desactivar pulso ahorra recursos
        color: Colors.deepOrangeAccent.withOpacity(0.15),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (!empty) {
      super.render(canvas);
    }
  }
}
