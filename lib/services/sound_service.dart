import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static Future<void> playTimerComplete() async {
    try {
      // Play system sound for timer completion
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing timer complete sound: $e');
    }
  }
  
  static Future<void> playTickSound() async {
    try {
      // Play a subtle tick sound (optional)
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing tick sound: $e');
    }
  }
  
  static Future<void> playFocusModeEnter() async {
    try {
      // Play a subtle sound when entering focus mode
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing focus mode sound: $e');
    }
  }
  
  static void dispose() {
    _audioPlayer.dispose();
  }
}
