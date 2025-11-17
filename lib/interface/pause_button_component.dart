import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/util/dialogs.dart';
import 'package:flutter/material.dart';

class PauseButtonComponent extends InterfaceComponent {
  bool _isPaused = false;
  
  PauseButtonComponent()
      : super(
          id: 2,
          position: Vector2(0, 20),
          size: Vector2(40, 40),
        ) {
    // Alta prioridad para recibir eventos táctiles primero
    priority = 100;
  }
  
  @override
  void onMount() {
    _updatePosition();
    super.onMount();
  }

  @override
  bool hasGesture() => true;

  // Actualizar posición para mantenerla correcta después de cambios de cámara o zoom
  void _updatePosition() {
    position = Vector2(
      gameRef.size.x - width - 20, // 20px desde la derecha
      20, // 20px desde arriba
    );
  }

  @override
  void update(double dt) {
    // Verificar y actualizar posición si es necesario (por cambios de zoom/cámara)
    if (position.x != gameRef.size.x - width - 20) {
      _updatePosition();
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Dibujar fondo del botón con borde más visible
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(8),
      ),
      bgPaint,
    );
    
    // Dibujar borde para hacerlo más visible
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(8),
      ),
      borderPaint,
    );
    
    // Dibujar icono de pausa (dos barras verticales)
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Barra izquierda
    canvas.drawRect(
      Rect.fromLTWH(12, 10, 6, 20),
      iconPaint,
    );
    
    // Barra derecha
    canvas.drawRect(
      Rect.fromLTWH(22, 10, 6, 20),
      iconPaint,
    );
    
    super.render(canvas);
  }

  @override
  bool containsPoint(Vector2 point) {
    // Área de toque más grande para facilitar la interacción
    final expandedRect = Rect.fromLTWH(
      position.x - 10,
      position.y - 10,
      width + 20,
      height + 20,
    );
    return expandedRect.contains(point.toOffset());
  }

  @override
  bool onTapDown(GestureEvent event) {
    if (!_isPaused && containsPoint(event.screenPosition)) {
      _isPaused = true;
      _showPauseMenu();
      return true;
    }
    return false;
  }

  void _showPauseMenu() {
    Dialogs.showPauseMenu(
      gameRef.context,
      onResume: () {
        _isPaused = false;
      },
      onRestart: () {
        _isPaused = false;
      },
      onMainMenu: () {
        _isPaused = false;
      },
    );
  }
}

