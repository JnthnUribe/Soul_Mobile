import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/interface/bar_life_component.dart';
import 'package:darkness_dungeon/player/knight.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:flutter/material.dart';

class KnightInterface extends GameInterface {
  late Sprite keySprite;
  final PlayerInventory inventory = PlayerInventory();

  @override
  Future<void> onLoad() async {
    keySprite = await Sprite.load('items/key_silver.png');
    add(MyBarLifeComponent());
    // Botones de pausa e inventario ahora están en Flutter directamente
    // add(PauseButtonComponent());
    // add(InventoryButtonComponent());
    
    await inventory.loadInventory();
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    try {
      _drawKey(canvas);
      _drawShieldIndicator(canvas);
    } catch (e) {}
    super.render(canvas);
  }

  void _drawKey(Canvas c) {
    if (gameRef.player != null && (gameRef.player as Knight).containKey) {
      keySprite.renderRect(c, Rect.fromLTWH(150, 20, 35, 30));
    }
  }
  
  void _drawShieldIndicator(Canvas canvas) {
    // Optimizado: Verificación temprana para evitar cálculos innecesarios
    if (gameRef.player == null) return;
    
    final knight = gameRef.player as Knight;
    
    // Solo mostrar si el escudo está activo
    if (!knight.isInvincible || knight.invincibilityTimeLeft <= 0) return;
    
    // Posición centrada en la parte superior de la pantalla
    final screenWidth = gameRef.size.x;
    final centerX = screenWidth / 2;
    
    // Dibujar fondo semi-transparente más ancho
    final bgRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(centerX - 95, 10, 190, 48),
          Radius.circular(12),
    );
    
    final bgPaint = Paint()
          ..color = Colors.black.withOpacity(0.7)
          ..style = PaintingStyle.fill;
    
    canvas.drawRRect(bgRect, bgPaint);
    
    // Dibujar borde brillante cyan
    final borderPaint = Paint()
          ..color = Colors.cyan.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    
    canvas.drawRRect(bgRect, borderPaint);
    
    // Dibujar ícono de escudo (círculo con borde)
    final shieldCenter = Offset(centerX - 65, 33);
    final shieldPaint = Paint()
          ..color = Colors.cyan.withOpacity(0.3)
          ..style = PaintingStyle.fill;
    
    canvas.drawCircle(shieldCenter, 12, shieldPaint);
    
    final shieldBorderPaint = Paint()
          ..color = Colors.cyan
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    
    canvas.drawCircle(shieldCenter, 12, shieldBorderPaint);
    
    // Dibujar texto "ESCUDO ACTIVO"
    final titlePaint = TextPaint(
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 11,
            fontFamily: 'Normal',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black,
              ),
            ],
          ),
    );
    
    titlePaint.render(
      canvas,
      '🛡️ ESCUDO ACTIVO',
      Vector2(centerX - 42, 19),
    );
    
    // Dibujar tiempo restante
    final timePaint = TextPaint(
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Normal',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black,
              ),
            ],
          ),
    );
    
    final timeText = '${knight.invincibilityTimeLeft.toInt()}s';
    timePaint.render(
      canvas,
      timeText,
      Vector2(centerX - 12, 37),
    );
    
    // Dibujar barra de progreso
    final progressBarWidth = 165.0;
    final progressBarHeight = 4.0;
    final progressX = centerX - 82;
    final progressY = 52.0;
    
    // Fondo de la barra
    final progressBgPaint = Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(progressX, progressY, progressBarWidth, progressBarHeight),
        Radius.circular(2),
      ),
      progressBgPaint,
    );
    
    // Barra de progreso (tiempo restante)
    final progress = knight.invincibilityTimeLeft / 30.0; // 30 segundos es el máximo
    final progressFillWidth = progressBarWidth * progress;
    
    // Color que cambia de cyan a amarillo a rojo según el tiempo
    Color progressColor;
    if (progress > 0.5) {
      progressColor = Colors.cyan;
    } else if (progress > 0.25) {
      progressColor = Colors.yellow;
    } else {
      progressColor = Colors.orange;
    }
    
    final progressFillPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(progressX, progressY, progressFillWidth, progressBarHeight),
        Radius.circular(2),
      ),
      progressFillPaint,
    );
  }
}
