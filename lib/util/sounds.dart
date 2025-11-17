import 'package:flame_audio/flame_audio.dart';

class Sounds {
  static Future initialize() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'attack_player.mp3',
      'attack_fire_ball.wav',
      'attack_enemy.mp3',
      'explosion.wav',
      'sound_interaction.wav',
    ]);
  }

  static void attackPlayerMelee() {
    FlameAudio.play('attack_player.mp3', volume: 0.4);
  }

  static void attackRange() {
    FlameAudio.play('attack_fire_ball.wav', volume: 0.3);
  }

  static void attackEnemyMelee() {
    FlameAudio.play('attack_enemy.mp3', volume: 0.4);
  }

  static void explosion() {
    FlameAudio.play('explosion.wav');
  }

  static void interaction() {
    FlameAudio.play('sound_interaction.wav', volume: 0.4);
  }

  static stopBackgroundSound() {
    return FlameAudio.bgm.stop();
  }

  static Future<void> playBackgroundSound() async {
    try {
      print('🎵 Intentando reproducir música...');
      
      // Detener primero si hay algo reproduciéndose
      try {
        await FlameAudio.bgm.stop();
        print('⏹️ Música anterior detenida');
      } catch (e) {
        print('⚠️ No había música para detener: $e');
      }
      
      // Pequeña pausa antes de reproducir
      await Future.delayed(Duration(milliseconds: 100));
      
      // Reproducir música de fondo
      await FlameAudio.bgm.play('sound_bg.mp3', volume: 1.0);
      print('✅ Música de fondo iniciada correctamente');
      
    } catch (e) {
      print('❌ Error al reproducir música: $e');
    }
  }

  static void playBackgroundBoosSound() {
    FlameAudio.bgm.play('battle_boss.mp3');
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
      // Solo detener la música, NO hacer dispose
      // (dispose() destruye el player y no se puede volver a usar)
      print('🔇 Deteniendo música...');
      await FlameAudio.bgm.stop();
      print('✅ Música detenida correctamente');
    } catch (e) {
      print('⚠️ Error al detener sonidos: $e');
    }
  }
}
