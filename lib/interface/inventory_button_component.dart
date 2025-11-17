import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:flutter/material.dart';

class InventoryButtonComponent extends InterfaceComponent {
  final PlayerInventory inventory = PlayerInventory();
  
  InventoryButtonComponent()
      : super(
          id: 3,
          position: Vector2(0, 70),
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
      gameRef.size.x - width - 20,
      70, // Debajo del botón de pausa
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
      ..color = Colors.amber.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(8),
      ),
      borderPaint,
    );
    
    // Dibujar icono de mochila/inventario
    final iconPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    // Dibujar mochila simplificada
    // Cuerpo de la mochila
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 12, 20, 18),
        Radius.circular(3),
      ),
      iconPaint,
    );
    
    // Tapa de la mochila
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 10, 16, 6),
        Radius.circular(2),
      ),
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
    if (containsPoint(event.screenPosition)) {
      _showInventoryPanel();
      return true;
    }
    return false;
  }

  void _showInventoryPanel() {
    showDialog(
      context: gameRef.context,
      barrierDismissible: true,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 300,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🎒 INVENTARIO',
                        style: TextStyle(
                          color: Colors.amber,
                          fontFamily: 'Normal',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  
                  Divider(color: Colors.amber.withOpacity(0.3), thickness: 2, height: 10),
                  
                  // Contenido con scroll
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          
                          // Sección de Consumibles
                          _buildSectionTitle('CONSUMIBLES'),
                  
                  _buildInventoryItem(
                    '🛡️',
                    'Escudo Mágico',
                    inventory.getConsumableQuantity('invincibility_30s'),
                    Colors.cyan,
                  ),
                  
                  _buildInventoryItem(
                    '🧪',
                    'Poción Pequeña',
                    inventory.getConsumableQuantity('potion_small'),
                    Colors.red,
                  ),
                  
                  _buildInventoryItem(
                    '🧪',
                    'Poción Mediana',
                    inventory.getConsumableQuantity('potion_medium'),
                    Colors.orange,
                  ),
                  
                  _buildInventoryItem(
                    '🧪',
                    'Poción Grande',
                    inventory.getConsumableQuantity('potion_large'),
                    Colors.purple,
                  ),
                  
                  _buildInventoryItem(
                    '🔑',
                    'Llaves',
                    inventory.getConsumableQuantity('key_single') + 
                    inventory.getConsumableQuantity('key_pack_3') * 3,
                    Colors.yellow,
                  ),
                  
                  SizedBox(height: 15),
                  
                  // Sección de Mejoras Permanentes
                  _buildSectionTitle('MEJORAS PERMANENTES'),
                  
                  _buildUpgradeStatus('⚔️ Espada Mejorada', 
                    inventory.hasPermanentUpgrade('weapon_upgrade_1')),
                  
                  _buildUpgradeStatus('⚔️ Espada Legendaria', 
                    inventory.hasPermanentUpgrade('weapon_upgrade_2')),
                  
                  _buildUpgradeStatus('👟 Botas de Velocidad', 
                    inventory.hasPermanentUpgrade('speed_upgrade_1')),
                  
                  _buildUpgradeStatus('💎 Amuleto de Stamina', 
                    inventory.hasPermanentUpgrade('stamina_upgrade_1')),
                  
                  _buildUpgradeStatus('💎 Amuleto Supremo', 
                    inventory.hasPermanentUpgrade('stamina_upgrade_2')),
                  
                  _buildUpgradeStatus('❤️ Corazón de Vida', 
                    inventory.hasPermanentUpgrade('health_upgrade_1')),
                  
                  _buildUpgradeStatus('❤️ Corazón Legendario', 
                    inventory.hasPermanentUpgrade('health_upgrade_2')),
                  
                  SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cerrar',
                        style: TextStyle(
                          fontFamily: 'Normal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber,
          fontFamily: 'Normal',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
  
  Widget _buildInventoryItem(String emoji, String name, int quantity, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: quantity > 0 ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: quantity > 0 ? Colors.white : Colors.grey,
                  fontFamily: 'Normal',
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: quantity > 0 ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'x$quantity',
              style: TextStyle(
                color: quantity > 0 ? color : Colors.grey,
                fontFamily: 'Normal',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpgradeStatus(String name, bool hasUpgrade) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasUpgrade ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: hasUpgrade ? Colors.white : Colors.grey,
              fontFamily: 'Normal',
              fontSize: 11,
            ),
          ),
          Icon(
            hasUpgrade ? Icons.check_circle : Icons.cancel,
            color: hasUpgrade ? Colors.green : Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }
}

