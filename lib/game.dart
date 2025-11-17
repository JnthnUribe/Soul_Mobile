import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/decoration/door.dart';
import 'package:darkness_dungeon/decoration/key.dart';
import 'package:darkness_dungeon/decoration/potion_life.dart';
import 'package:darkness_dungeon/decoration/spikes.dart';
import 'package:darkness_dungeon/decoration/torch.dart';
import 'package:darkness_dungeon/enemies/boss.dart';
import 'package:darkness_dungeon/enemies/goblin.dart';
import 'package:darkness_dungeon/enemies/imp.dart';
import 'package:darkness_dungeon/enemies/mini_boss.dart';
import 'package:darkness_dungeon/interface/knight_interface.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/npc/kid.dart';
import 'package:darkness_dungeon/npc/wizard_npc.dart';
import 'package:darkness_dungeon/player/knight.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:darkness_dungeon/util/dialogs.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:darkness_dungeon/widgets/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

class Game extends StatefulWidget {
  static bool useJoystick = true;
  static bool isRestarting = false; // Flag para evitar detener música al reiniciar
  
  const Game({Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  BonfireGameInterface? gameRef; // Referencia al juego para limpiarlo correctamente
  
  @override
  void initState() {
    super.initState();
    print('🎮 Iniciando nuevo juego... (isRestarting: ${Game.isRestarting})');
    
    // Siempre iniciar la música, sin importar si es reinicio o no
    _startBackgroundMusic();
  }
  
  Future<void> _startBackgroundMusic() async {
    // Esperar más tiempo si es un reinicio para que dispose() termine primero
    final delayTime = Game.isRestarting ? 600 : 300;
    await Future.delayed(Duration(milliseconds: delayTime));
    
    if (mounted) {
      await Sounds.playBackgroundSound();
    }
  }

  @override
  void dispose() {
    // Limpieza completa para evitar juegos sobrepuestos
    print('🧹 Limpiando juego... (isRestarting: ${Game.isRestarting})');
    
    // IMPORTANTE: Si estamos reiniciando, NO detener la música
    // porque el nuevo juego usará el mismo reproductor
    if (!Game.isRestarting) {
      try {
        FlameAudio.bgm.stop();
        print('🔇 Música detenida (no es reinicio)');
      } catch (e) {
        print('⚠️ Error al detener música: $e');
      }
    } else {
      print('♻️ Reiniciando - NO deteniendo música para el nuevo juego');
      // AHORA SÍ resetear el flag DESPUÉS de verificarlo
      Game.isRestarting = false;
    }
    
    // Detener y limpiar el juego si existe
    if (gameRef != null) {
      try {
        // Pausar el game loop primero
        gameRef!.pauseEngine();
        
        // Limpiar overlays
        try {
          gameRef!.overlays.clear();
        } catch (e) {
          print('⚠️ Error al limpiar overlays: $e');
        }
        
        // Remover TODOS los componentes recursivamente
        if (gameRef is BonfireGame) {
          final bonfireGame = gameRef as BonfireGame;
          
          // Limpiar múltiples veces para asegurar que se eliminen todos
          for (int i = 0; i < 3; i++) {
            try {
              final components = List.from(bonfireGame.children);
              print('🗑️ Removiendo ${components.length} componentes (iteración ${i + 1})');
              for (var component in components) {
                try {
                  component.removeFromParent();
                } catch (e) {
                  // Ignorar errores individuales
                }
              }
            } catch (e) {
              print('⚠️ Error en iteración $i: $e');
            }
          }
        }
        
        // Limpiar la referencia
        gameRef = null;
        
      } catch (e) {
        print('❌ Error al limpiar el juego: $e');
      }
    }
    
    print('✅ Juego limpiado completamente');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlayerController joystick = Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: 100,
        isFixed: false,
      ),
      actions: [
        JoystickAction(
          actionId: 0,
          sprite: Sprite.load('joystick_atack.png'),
          spritePressed: Sprite.load('joystick_atack_selected.png'),
          size: 80,
          margin: EdgeInsets.only(bottom: 50, right: 50),
        ),
        JoystickAction(
          actionId: 1,
          sprite: Sprite.load('joystick_atack_range.png'),
          spritePressed: Sprite.load('joystick_atack_range_selected.png'),
          size: 50,
          margin: EdgeInsets.only(bottom: 50, right: 160),
        ),
        JoystickAction(
          actionId: 2,
          sprite: Sprite.load('joystick_atack.png'), // Escudo
          spritePressed: Sprite.load('joystick_atack_selected.png'),
          size: 50,
          margin: EdgeInsets.only(bottom: 120, right: 160),
        ),
        JoystickAction(
          actionId: 3,
          sprite: Sprite.load('joystick_atack_range.png'), // Poción
          spritePressed: Sprite.load('joystick_atack_range_selected.png'),
          size: 50,
          margin: EdgeInsets.only(bottom: 120, right: 50),
        )
      ],
    );

    if (!Game.useJoystick) {
      joystick = Keyboard(
        config: KeyboardConfig(
          directionalKeys: [KeyboardDirectionalKeys.arrows()],
          acceptedKeys: [
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.keyZ,
            LogicalKeyboardKey.keyX,
            LogicalKeyboardKey.keyC,
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          BonfireWidget(
            onReady: (game) {
              // Guardar referencia al juego para limpiarlo en dispose()
              gameRef = game;
            },
            playerControllers: [
              joystick,
            ],
            player: Knight(
              Vector2(2 * tileSize, 3 * tileSize),
            ),
        map: WorldMapByTiled(
          WorldMapReader.fromAsset('tiled/map.json'),
          forceTileSize: Vector2(tileSize, tileSize),
          objectsBuilder: {
            'door': (p) => Door(p.position, p.size),
            'torch': (p) => Torch(p.position),
            'potion': (p) => PotionLife(p.position, 30),
            'wizard': (p) => WizardNPC(p.position),
            'spikes': (p) => Spikes(p.position),
            'key': (p) => DoorKey(p.position),
            'kid': (p) => Kid(p.position),
            'boss': (p) => Boss(p.position),
            'goblin': (p) => Goblin(p.position),
            'imp': (p) => Imp(p.position),
            'mini_boss': (p) => MiniBoss(p.position),
            'torch_empty': (p) => Torch(p.position, empty: true),
          },
        ),
        components: [GameController()],
        interface: KnightInterface(),
        // Reducir opacidad de iluminación para mejor rendimiento
        lightingColorGame: Colors.black.withOpacity(0.4),
        backgroundColor: Colors.grey[900]!,
        cameraConfig: CameraConfig(
          speed: 3,
          zoom: getZoomFromMaxVisibleTile(context, tileSize, 18),
        ),
        // progress: Container(
        //   color: Colors.black,
        //   child: Center(
        //     child: Text(
        //       "Loading...",
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontFamily: 'Normal',
        //         fontSize: 20.0,
        //       ),
        //     ),
        //   ),
        // ),
          ),
          // Botones de UI siempre encima de todo (no se bloquean con diálogos)
          _buildUIButtons(context),
        ],
      ),
    );
  }

  // Construir botones de UI que siempre estén encima
  Widget _buildUIButtons(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Botón de Pausa
          Positioned(
            top: 20,
            right: 20,
            child: _PauseButton(),
          ),
          // Botón de Inventario
          Positioned(
            top: 70,
            right: 20,
            child: _InventoryButton(),
          ),
        ],
      ),
    );
  }
}

// Botón de Pausa como Widget de Flutter
class _PauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Dialogs.showPauseMenu(
          context,
          onResume: () {},
          onRestart: () {},
          onMainMenu: () {},
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Barra izquierda
            Container(
              width: 6,
              height: 20,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            // Barra derecha
            Container(
              width: 6,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// Botón de Inventario como Widget de Flutter
class _InventoryButton extends StatefulWidget {
  @override
  _InventoryButtonState createState() => _InventoryButtonState();
}

class _InventoryButtonState extends State<_InventoryButton> {
  final PlayerInventory inventory = PlayerInventory();

  @override
  void initState() {
    super.initState();
    inventory.loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showInventoryPanel(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.amber.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.inventory_2_outlined,
          color: Colors.amber,
          size: 24,
        ),
      ),
    );
  }

  void _showInventoryPanel(BuildContext context) async {
    // Recargar inventario para asegurar datos actualizados
    await inventory.loadInventory();
    
    showDialog(
      context: context,
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
