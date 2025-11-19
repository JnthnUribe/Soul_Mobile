import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Knight extends SimplePlayer with Lighting, BlockMovementCollision {
  double baseAttack = 25;
  double attack = 25;
  double baseStamina = 100;
  double stamina = 100;
  double maxStamina = 100;
  double baseSpeed = 0;
  async.Timer? _timerStamina;
  bool containKey = false;
  bool showObserveEnemy = false;
  final PlayerInventory inventory = PlayerInventory();
  
  // Sistema de invencibilidad
  bool isInvincible = false;
  async.Timer? _invincibilityTimer;
  CircleComponent? _shieldEffect;
  double invincibilityTimeLeft = 0;
  DateTime? _invincibilityStartTime;
  int _invincibilityDuration = 0;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.playerAnimations(),
          size: Vector2.all(tileSize),
          position: position,
          life: 200,
          speed: tileSize * 2.5,
        ) {
    baseSpeed = tileSize * 2.5;
    // Optimizado: Reducir iluminación del jugador para mejor rendimiento
    setupLighting(
      LightingConfig(
        radius: width * 1.2,
        blurBorder: width * 0.6,
        color: Colors.deepOrangeAccent.withOpacity(0.15),
      ),
    );
    setupMovementByJoystick(intensityEnabled: true);
    _loadInventoryAndApplyUpgrades();
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(valueByTileSize(8), valueByTileSize(8)),
        position: Vector2(
          valueByTileSize(4),
          valueByTileSize(8),
        ),
      ),
    );
    return super.onLoad();
  }
  
  // Cargar inventario y aplicar mejoras permanentes
  Future<void> _loadInventoryAndApplyUpgrades() async {
    await inventory.loadInventory();
    _applyPermanentUpgrades();
  }
  
  // Aplicar todas las mejoras permanentes compradas
  void _applyPermanentUpgrades() {
    // Resetear a valores base
    attack = baseAttack;
    maxStamina = baseStamina;
    speed = baseSpeed;
    
    // Aplicar mejoras de arma
    if (inventory.hasPermanentUpgrade('weapon_upgrade_1')) {
      attack += 10;
    }
    if (inventory.hasPermanentUpgrade('weapon_upgrade_2')) {
      attack += 20;
    }
    
    // Aplicar mejoras de stamina
    if (inventory.hasPermanentUpgrade('stamina_upgrade_1')) {
      maxStamina += 50;
    }
    if (inventory.hasPermanentUpgrade('stamina_upgrade_2')) {
      maxStamina += 100;
    }
    
    // Aplicar mejoras de velocidad
    if (inventory.hasPermanentUpgrade('speed_upgrade_1')) {
      speed = baseSpeed * 1.3;
    }
    
    // Aplicar mejoras de vida máxima
    double maxLifeBonus = 0;
    if (inventory.hasPermanentUpgrade('health_upgrade_1')) {
      maxLifeBonus += 50;
    }
    if (inventory.hasPermanentUpgrade('health_upgrade_2')) {
      maxLifeBonus += 100;
    }
    
    if (maxLifeBonus > 0) {
      // Aumentar vida máxima y curar proporcionalmente
      addLife(maxLifeBonus);
    }
  }
  
  // Usar poción del inventario
  Future<void> usePotion(String potionId) async {
    if (await inventory.useConsumableItem(potionId)) {
      final item = _getPotionEffect(potionId);
      if (item != null) {
        addLife(item);
        _showHealEffect();
      }
    }
  }
  
  // Usar la mejor poción disponible automáticamente
  Future<void> useBestAvailablePotion() async {
    // Si la vida está completa, no usar poción
    if (life >= maxLife) {
      return;
    }
    
    double missingLife = maxLife - life;
    
    // Intentar usar la poción más apropiada según la vida faltante
    // Prioridad: usar la más pequeña que sea suficiente para no desperdiciar
    
    if (missingLife <= 50 && inventory.getConsumableQuantity('potion_small') > 0) {
      await usePotion('potion_small');
    } else if (missingLife <= 100 && inventory.getConsumableQuantity('potion_medium') > 0) {
      await usePotion('potion_medium');
    } else if (inventory.getConsumableQuantity('potion_large') > 0) {
      await usePotion('potion_large');
    } else if (inventory.getConsumableQuantity('potion_medium') > 0) {
      await usePotion('potion_medium');
    } else if (inventory.getConsumableQuantity('potion_small') > 0) {
      await usePotion('potion_small');
    }
    // Si no tiene pociones, no hace nada
  }
  
  double? _getPotionEffect(String potionId) {
    switch (potionId) {
      case 'potion_small':
        return 50;
      case 'potion_medium':
        return 100;
      case 'potion_large':
        return 200;
      default:
        return null;
    }
  }
  
  void _showHealEffect() {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          'emote/emote_interregacao.png',
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        loop: false,
        size: Vector2.all(tileSize / 2),
        offset: Vector2(18, -6),
      ),
    );
  }
  
  // Usar llave del inventario
  Future<bool> useKeyFromInventory() async {
    if (await inventory.useConsumableItem('key_single') ||
        await inventory.useConsumableItem('key_pack_3')) {
      containKey = true;
      return true;
    }
    return false;
  }
  
  // Usar escudo de invencibilidad del inventario
  Future<void> useInvincibilityShield() async {
    // No usar si ya está activo
    if (isInvincible) {
      return;
    }
    
    // Verificar si tiene el ítem en el inventario
    if (await inventory.useConsumableItem('invincibility_30s')) {
      _activateInvincibility(30); // 30 segundos
    }
  }
  
  // Activar invencibilidad por un tiempo determinado
  void _activateInvincibility(int seconds) {
    isInvincible = true;
    _invincibilityDuration = seconds;
    _invincibilityStartTime = DateTime.now();
    invincibilityTimeLeft = seconds.toDouble();
    
    // Cancelar timer anterior si existe
    _invincibilityTimer?.cancel();
    
    // Mostrar efecto visual del escudo
    _showShieldEffect();
    
    // Timer para desactivar la invencibilidad
    _invincibilityTimer = async.Timer(
      Duration(seconds: seconds),
      () {
        isInvincible = false;
        invincibilityTimeLeft = 0;
        _invincibilityStartTime = null;
        _removeShieldEffect();
      },
    );
  }
  
  // Mostrar efecto visual del escudo (Optimizado)
  void _showShieldEffect() {
    if (!isMounted || !hasGameRef) return;
    
    _removeShieldEffect(); // Remover efecto anterior si existe
    
    // Crear un círculo brillante alrededor del jugador (simplificado para mejor rendimiento)
    _shieldEffect = CircleComponent(
      radius: tileSize * 0.75,
      position: center,
      anchor: Anchor.center,
      paint: Paint()
        ..color = Colors.cyan.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    
    if (_shieldEffect != null) {
      gameRef.add(_shieldEffect!);
      
      // Solo un efecto simple de parpadeo (más eficiente)
      _shieldEffect!.add(
        OpacityEffect.fadeOut(
          EffectController(
            duration: 1.0,
            infinite: true,
            reverseDuration: 1.0,
          ),
        ),
      );
      // Removido ScaleEffect para mejor rendimiento
    }
  }
  
  // Remover efecto visual del escudo
  void _removeShieldEffect() {
    _shieldEffect?.removeFromParent();
    _shieldEffect = null;
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == LogicalKeyboardKey.space &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == LogicalKeyboardKey.keyZ &&
        event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }
    
    // Activar escudo de invencibilidad con tecla X o botón 2
    if (event.id == LogicalKeyboardKey.keyX &&
        event.event == ActionEvent.DOWN) {
      useInvincibilityShield();
    }
    
    if (event.id == 2 && event.event == ActionEvent.DOWN) {
      useInvincibilityShield();
    }
    
    // Usar poción con tecla C o botón 3
    if (event.id == LogicalKeyboardKey.keyC &&
        event.event == ActionEvent.DOWN) {
      useBestAvailablePotion();
    }
    
    if (event.id == 3 && event.event == ActionEvent.DOWN) {
      useBestAvailablePotion();
    }
    
    super.onJoystickAction(event);
  }

  @override
  void onDie() {
    // Limpiar timers y efectos
    _invincibilityTimer?.cancel();
    _removeShieldEffect();
    isInvincible = false;
    invincibilityTimeLeft = 0;
    _invincibilityStartTime = null;
    
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: Vector2(
          position.x,
          position.y,
        ),
        size: Vector2.all(30),
      ),
    );
    super.onDie();
  }
  
  @override
  void onRemove() {
    // Limpiar timers al remover el componente
    _timerStamina?.cancel();
    _invincibilityTimer?.cancel();
    _removeShieldEffect();
    isInvincible = false;
    invincibilityTimeLeft = 0;
    _invincibilityStartTime = null;
    super.onRemove();
  }

  void actionAttack() {
    if (stamina < 15) {
      return;
    }

    // Verificar que el componente esté montado antes de atacar
    if (!isMounted || !hasGameRef) {
      return;
    }

    Sounds.attackPlayerMelee();
    decrementStamina(15);
    simpleAttackMelee(
      damage: attack,
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      size: Vector2.all(tileSize),
    );
  }

  void actionAttackRange() {
    if (stamina < 10) {
      return;
    }

    // Verificar que el componente esté montado antes de atacar
    if (!isMounted || !hasGameRef) {
      return;
    }

    Sounds.attackRange();

    decrementStamina(10);
    simpleAttackRange(
      animationRight: GameSpriteSheet.fireBallAttackRight(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      size: Vector2(tileSize * 0.65, tileSize * 0.65),
      damage: 10,
      speed: speed * 2.5,
      onDestroy: () {
        Sounds.explosion();
      },
      collision: RectangleHitbox(
        size: Vector2(tileSize / 3, tileSize / 3),
        position: Vector2(10, 5),
      ),
      // Removido lightingConfig para mejor rendimiento en móviles
    );
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _verifyStamina();
    
    // Optimizado: Actualizar posición del escudo solo si está activo
    if (isInvincible && _shieldEffect != null && _shieldEffect!.isMounted) {
      _shieldEffect!.position = center;
      
      // Optimizado: Calcular tiempo restante solo cada 0.5 segundos
      if (_invincibilityStartTime != null && checkInterval('updateInvTime', 500, dt)) {
        final elapsed = DateTime.now().difference(_invincibilityStartTime!).inSeconds;
        invincibilityTimeLeft = (_invincibilityDuration - elapsed).toDouble();
        if (invincibilityTimeLeft < 0) invincibilityTimeLeft = 0;
      }
    }
    
    // Optimizado: Verificar enemigos con menos frecuencia y menor radio
    if (checkInterval('checkEnemies', 200, dt)) {
      seeEnemy(
        radiusVision: tileSize * 5,
        notObserved: () {
          showObserveEnemy = false;
        },
        observed: (enemies) {
          if (showObserveEnemy) return;
          showObserveEnemy = true;
          _showEmote();
        },
      );
    }
    
    super.update(dt);
  }

  void _verifyStamina() {
    if (_timerStamina == null) {
      _timerStamina = async.Timer(
        Duration(milliseconds: 50),
        () {
          _timerStamina = null;
        },
      );
    } else {
      return;
    }

    stamina += 2;
    if (stamina > maxStamina) {
      stamina = maxStamina;
    }
  }

  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    
    // Si está invencible, no recibir daño
    if (isInvincible) {
      // Mostrar mensaje de que está protegido
      showDamage(
        0,
        config: TextStyle(
          fontSize: valueByTileSize(5),
          color: Colors.cyan,
          fontFamily: 'Normal',
        ),
      );
      return;
    }
    
    showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void _showEmote({String emote = 'emote/emote_exclamacao.png'}) {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          emote,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        loop: false,
        size: Vector2.all(tileSize / 2),
        offset: Vector2(18, -6),
      ),
    );
  }
}
