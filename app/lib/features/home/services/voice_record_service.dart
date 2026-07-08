import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceRecordService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _path;

  Future<File?> start() async {
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) return null;

    final dir = await getTemporaryDirectory();
    _path = '${dir.path}/voice_search_${DateTime.now().millisecondsSinceEpoch}.m4a';

    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _path!,
      );
      return File(_path!);
    }

    return null;
  }

  Future<File?> stop() async {
    await _recorder.stop();
    if (_path == null) return null;

    final file = File(_path!);
    if (!await file.exists() || await file.length() == 0) {
      return null;
    }
    return file;
  }
}
