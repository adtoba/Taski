import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taski/core/constants/enums.dart';
import 'package:taski/core/services/audio_recorder_service.dart';
import 'package:taski/core/di/globals.dart';
import 'package:taski/main.dart';


AudioRecorderProvider get audioRecorderProvider {
  final ctx = navigatorKey.currentContext!;
  final container = ProviderScope.containerOf(ctx, listen: false);
  return container.read(audioRecorderProviderRef);
}

class AudioRecorderProvider extends ChangeNotifier {

  AudioRecorderProvider get instance => this;

  final AudioRecorderService _audioRecorderService = sl.get(); // singleton

  Duration _recordingDuration = Duration.zero;
  Duration get recordingDuration => _recordingDuration;

  AudioRecordingState _recordingState = AudioRecordingState.notRecording;
  AudioRecordingState get recordingState => _recordingState;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  FlutterSoundPlayer get player => _player;

  int _timerCount = 0;
  int get timerCount => _timerCount;

  Timer? _timer;
  Timer? get timer => _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timerCount++;
      _recordingDuration = Duration(seconds: _timerCount);
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void cancelTimer() {
    _timerCount = 0;
    _recordingDuration = Duration.zero;
    _timer?.cancel();
    notifyListeners();
  }

  void updateRecordingState(AudioRecordingState state) {
    _recordingState = state;
    notifyListeners();
  }

  void resetRecordingState() {
    _recordingDuration = Duration.zero;
    _recordingState = AudioRecordingState.notRecording;
    notifyListeners();
  }

  void forceNotify() {
    notifyListeners();
  }
  

  Future<void> startRecording() async {
    await _audioRecorderService.startRecording();
  }

  Future<void> stopRecording() async {
    await _audioRecorderService.stopRecording();
  }

  Future<void> pause() async {
    await _audioRecorderService.pauseRecording();
    _recordingState = AudioRecordingState.notRecording;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioRecorderService.resumeRecording();
    _recordingState = AudioRecordingState.recording;
    notifyListeners();
  }

  Future<void> play() async {
    await _audioRecorderService.playRecording();
  }

  Future<void> playAudio({String? url, String? path}) async {
    try {
      if(!_player.isOpen()) {
        await _player.openPlayer();
      }

      String? uri;

      if(path == null) {
        uri = url;
      } else if(path.isNotEmpty) {
        final file = File(path);

        logger.i('File path: ${file.path}');
        logger.i('File exists: ${file.existsSync()}');

        if(file.existsSync()) {
          uri = file.path;
        } else {
          uri = url;
        }
      } else {
        uri = url;
      }

      await _player.startPlayer(
        fromURI: uri!,
      );
      
      
    } catch (e) {
      logger.e('Error playing audio: $e');
    }
  }

  Future<void> disposeRecorder() async {
    await _audioRecorderService.dispose();
  }
}


final audioRecorderProviderRef = ChangeNotifierProvider<AudioRecorderProvider>((ref) {
  return AudioRecorderProvider();
});