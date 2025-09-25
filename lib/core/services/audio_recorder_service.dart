import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taski/core/constants/enums.dart';
import 'package:taski/core/providers/audio_recorder_provider.dart';
import 'package:taski/core/providers/messages_provider.dart';
import 'package:taski/core/services/openai_service.dart';
import 'package:taski/main.dart';

abstract class AudioRecorderService {
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<void> playRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<void> dispose();
}

class AudioRecorderServiceImpl implements AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  AudioRecorderServiceImpl._();

  static final AudioRecorderServiceImpl _instance = AudioRecorderServiceImpl._();

  factory AudioRecorderServiceImpl() => _instance;

  bool isInitialized = false;

  String? _mPath;

  Future<String>  preparePath() async {
    if(_mPath == null) {
      final dir = await getTemporaryDirectory();
      _mPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";
    }
    return _mPath!;
  }

  Future<void> openRecorder() async {
    if(!isInitialized) {
      await _recorder.openRecorder();
      isInitialized = true;
    }
  }

  @override
  Future<void> startRecording() async {
    if(!isInitialized) {
      await openRecorder();
    }

    if(_recorder.isRecording) return;

    if(!await ensureMicPermission()) {
      logger.e("Microphone permission not granted");
      return;
    }

    await preparePath();

    // Reset the recording duration
    audioRecorderProvider.resetRecordingState();

    // Start the recording timer
    audioRecorderProvider.startTimer();

    try {
      await _recorder.startRecorder(
        toFile: _mPath,
        codec: Codec.aacMP4,
      );
    } catch (e) {
      logger.e("Error starting recorder:", error: e);
    }

    audioRecorderProvider.forceNotify();
  }

  @override
  Future<void> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      await messageProvider.sendUserMessageAndUploadAudio(
        filePath: _mPath!,
      );

      audioRecorderProvider.cancelTimer();
      audioRecorderProvider.updateRecordingState(AudioRecordingState.notRecording);
      audioRecorderProvider.forceNotify();

    } catch (e) {
      logger.e("Error stopping recorder:", error: e);
    }
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> pauseRecording() async {
    await _recorder.pauseRecorder();
    audioRecorderProvider.forceNotify();
  }

  @override
  Future<void> playRecording() async {
    await _player.openPlayer();
    await _player.startPlayer(
      fromURI: _mPath!,
      codec: Codec.aacADTS,
    );

    await _player.setVolume(1.0);
    await _player.setSpeed(1.0);
  }

  @override
  Future<void> resumeRecording() {
    // TODO: implement resumeRecording
    throw UnimplementedError();
  }

  Future<bool> ensureMicPermission() async {
    final status = await Permission.microphone.status;
    logger.d("Microphone permission status: $status");

    if (status.isGranted) return true;

    if (status.isDenied) {
      logger.d("Microphone permission is denied");
      final req = await Permission.microphone.request();
      logger.d("Microphone permission request status: ${req.isGranted}");
      return req.isGranted;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      // Show UI telling the user to enable mic in Settings, then:
      await openAppSettings();
      // Optionally re-check after returning from settings:
      return (await Permission.microphone.status).isGranted;
    }

    return false;
  }

}
