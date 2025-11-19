import 'package:flame_audio/flame_audio.dart';

class Sounds {
  // Control de tiempo para evitar spam de sonidos (debounce)
  static DateTime _lastAttackPlayer = DateTime.now();
  static DateTime _lastAttackRange = DateTime.now();
  static DateTime _lastAttackEnemy = DateTime.now();
  static DateTime _lastInteraction = DateTime.now();
  
  // Intervalo mínimo entre sonidos idénticos (en milisegundos)
  static const int _minInterval = 80; // Reducido ligeramente para mejor respuesta

  // Audio Pools para baja latencia
  static late AudioPool poolAttackPlayer;
  static late AudioPool poolAttackRange;
  static late AudioPool poolAttackEnemy;
  static late AudioPool poolExplosion;
  static late AudioPool poolInteraction;

  static Future initialize() async {
    FlameAudio.bgm.initialize();
    
    // Inicializar Pools (pre-carga sonidos en memoria para reproducción instantánea)
    // maxPlayers: 1 significa que si se llama de nuevo mientras suena, se corta o ignora según config.
    // Para efectos rápidos, queremos permitir solapamiento controlado.
    
    try {
      poolAttackPlayer = await FlameAudio.createPool(
        'attack_player.wav',
        minPlayers: 2,
        maxPlayers: 4,
      );
      
      poolAttackRange = await FlameAudio.createPool(
        'attack_fire_ball.wav',
        minPlayers: 2,
        maxPlayers: 4,
      );
      
      poolAttackEnemy = await FlameAudio.createPool(
        'attack_enemy.wav',
        minPlayers: 2,
        maxPlayers: 4,
      );
      
      poolExplosion = await FlameAudio.createPool(
        'explosion.wav',
        minPlayers: 2,
        maxPlayers: 5,
      );
      
      poolInteraction = await FlameAudio.createPool(
        'sound_interaction.wav',
        minPlayers: 1,
        maxPlayers: 2,
      );
      
      print('✅ AudioPools inicializados correctamente');
    } catch (e) {
      print('❌ Error al inicializar AudioPools: $e');
    }
  }

  static bool _canPlay(DateTime lastTime) {
    return DateTime.now().difference(lastTime).inMilliseconds > _minInterval;
  }

  static void attackPlayerMelee() {
    if (_canPlay(_lastAttackPlayer)) {
      _lastAttackPlayer = DateTime.now();
      try {
        poolAttackPlayer.start(volume: 0.4);
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  static void attackRange() {
    if (_canPlay(_lastAttackRange)) {
      _lastAttackRange = DateTime.now();
      try {
        poolAttackRange.start(volume: 0.3);
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  static void attackEnemyMelee() {
    if (_canPlay(_lastAttackEnemy)) {
      _lastAttackEnemy = DateTime.now();
      try {
        poolAttackEnemy.start(volume: 0.4);
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  static void explosion() {
    try {
      poolExplosion.start();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  static void interaction() {
    if (_canPlay(_lastInteraction)) {
      _lastInteraction = DateTime.now();
      try {
        poolInteraction.start(volume: 0.4);
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  static void stopBackgroundSound() {
    FlameAudio.bgm.stop();
  }

  static Future<void> playBackgroundSound() async {
    // Deshabilitado por rendimiento
    return;
  }

  static void playBackgroundBoosSound() {
    // Deshabilitado por rendimiento
    return;
  }

  static void pauseBackgroundSound() {
    FlameAudio.bgm.pause();
  }

  static void resumeBackgroundSound() {
    FlameAudio.bgm.resume();
  }

  static void dispose() {
    FlameAudio.bgm.dispose();
  }

  static Future<void> cleanupAll() async {
    try {
      print('🔇 Deteniendo todos los sonidos...');
      await FlameAudio.bgm.stop();
      // No necesitamos limpiar caché si usamos Pools, pero podemos detener bgm
      print('✅ Sonidos detenidos');
    } catch (e) {
      print('⚠️ Error al detener sonidos: $e');
    }
  }
}
