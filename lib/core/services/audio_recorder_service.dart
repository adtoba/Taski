import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taski/core/constants/enums.dart';
import 'package:taski/core/providers/audio_recorder_provider.dart';
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

  AudioRecorderServiceImpl._();

  static final AudioRecorderServiceImpl _instance = AudioRecorderServiceImpl._();

  factory AudioRecorderServiceImpl() => _instance;

  bool isInitialized = false;

  String? _mPath;

  Future<String>  preparePath() async {
    if(_mPath == null) {
      final dir = await getTemporaryDirectory();
      _mPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac";
    }
    return _mPath!;
  }

  Future<void> openRecorder() async {
    var status = await Permission.microphone.request();
    if(status != PermissionStatus.granted) {
      throw Exception("Microphone permission not granted");
    }

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

    await preparePath();

    // Reset the recording duration
    audioRecorderProvider.resetRecordingState();

    // Start the recording timer
    audioRecorderProvider.startTimer();

    try {
      await _recorder.startRecorder(
        toFile: _mPath,
        codec: Codec.aacADTS,
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
  Future<void> playRecording() {
    // TODO: implement playRecording
    throw UnimplementedError();
  }

  @override
  Future<void> resumeRecording() {
    // TODO: implement resumeRecording
    throw UnimplementedError();
  }

  

  

}
