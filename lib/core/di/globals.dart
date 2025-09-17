import 'package:get_it/get_it.dart';
import 'package:taski/core/services/audio_recorder_service.dart';

// Global singletons for non-UI access


final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory<AudioRecorderService>(() => AudioRecorderServiceImpl());
}