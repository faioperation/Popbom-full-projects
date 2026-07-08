// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class TextVoiceVideoScreen extends StatefulWidget {
//   const TextVoiceVideoScreen({super.key});
//
//   @override
//   State<TextVoiceVideoScreen> createState() => _TextVoiceVideoScreenState();
// }
//
// class _TextVoiceVideoScreenState extends State<TextVoiceVideoScreen> {
//   final _textController = TextEditingController();
//   final Record _recorder = Record();
//
//   bool _isRecording = false;
//   String? _recordFilePath;
//
//   bool _isGenerating = false;
//   double _progress = 0.0;
//
//   Uint8List? _videoBytes;
//   String? _videoFilePath;
//
//   static const String VIDEO_API_ENDPOINT = "https://your-api.com/generate";
//   static const String AUTH = "Bearer YOUR_TOKEN";
//
//   @override
//   void dispose() {
//     _textController.dispose();
//     _recorder.dispose();
//     super.dispose();
//   }
//
//   Future<void> _startOrStopRecording() async {
//     try {
//       bool hasPermission = await _recorder.hasPermission();
//       if (!hasPermission) {
//         _showMessage("Microphone permission denied!");
//         return;
//       }
//
//       if (!_isRecording) {
//         final dir = await getTemporaryDirectory();
//         final path =
//             "${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a";
//
//         await _recorder.start(
//           path: path,
//           encoder: AudioEncoder.aacLc,
//           bitRate: 128000,
//           samplingRate: 44100,
//         );
//
//         setState(() {
//           _isRecording = true;
//           _recordFilePath = path;
//         });
//       } else {
//         final path = await _recorder.stop();
//         setState(() {
//           _isRecording = false;
//           _recordFilePath = path;
//         });
//       }
//     } catch (e) {
//       _showMessage("Record Error: $e");
//       setState(() => _isRecording = false);
//     }
//   }
//
//   Future<void> _generateVideo({required String type}) async {
//     try {
//       setState(() {
//         _isGenerating = true;
//         _progress = 0.3;
//         _videoBytes = null;
//         _videoFilePath = null;
//       });
//
//       final uri = Uri.parse(VIDEO_API_ENDPOINT);
//       final req = http.MultipartRequest("POST", uri);
//       req.headers["Authorization"] = AUTH;
//
//       req.fields["type"] = type;
//
//       if (type == "text") {
//         req.fields["text"] = _textController.text;
//       } else {
//         req.files.add(await http.MultipartFile.fromPath(
//           "audio",
//           _recordFilePath!,
//         ));
//       }
//
//       final resp = await req.send();
//       setState(() => _progress = 0.6);
//
//       if (resp.statusCode == 200) {
//         Uint8List bytes = await resp.stream.toBytes();
//
//         final saved = await _saveVideo(bytes);
//
//         setState(() {
//           _videoBytes = bytes;
//           _videoFilePath = saved;
//           _progress = 1.0;
//         });
//       } else {
//         final body = await resp.stream.bytesToString();
//         _showMessage("Error ${resp.statusCode}: $body");
//       }
//     } catch (e) {
//       _showMessage("Generation error: $e");
//     } finally {
//       setState(() => _isGenerating = false);
//     }
//   }
//
//   Future<String> _saveVideo(Uint8List bytes) async {
//     final dir = await getTemporaryDirectory();
//     final path = "${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4";
//     final file = File(path);
//     await file.writeAsBytes(bytes);
//     return path;
//   }
//
//
//   void _showMessage(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }
//
//   Future<void> _openFile() async {
//     if (_videoFilePath == null) return;
//     await launchUrl(
//       Uri.file(_videoFilePath!),
//       mode: LaunchMode.externalApplication,
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("AI Video Generator"),
//         centerTitle: true,
//       ),
//
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//
//               _buildInputCard(cs),
//
//               const SizedBox(height: 16),
//               _buildActionButtons(),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: _buildPreview(cs),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputCard(ColorScheme cs) {
//     return Column(
//       children: [
//         SizedBox(height: 16,),
//         TextField(
//           controller: _textController,
//           maxLines: 4,
//           decoration: const InputDecoration(
//             hintText: "Describe the video you want to generate...",
//             border: OutlineInputBorder(),
//           ),
//         ),
//
//         const SizedBox(height: 22),
//
//         Row(
//           children: [
//             ElevatedButton.icon(
//               icon: Icon(_isRecording ? Icons.stop : Icons.mic),
//               label: Text(_isRecording ? "Stop" : "Record Voice"),
//               onPressed: _startOrStopRecording,
//             ),
//             const SizedBox(width: 12),
//             if (_recordFilePath != null)
//               Text(
//                 "Voice saved",
//                 style: TextStyle(color: cs.primary),
//               ),
//           ],
//         )
//       ],
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: _isGenerating ? null : () => _generateVideo(type: "text"),
//             child: const Text("Generate from Text"),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: (_isGenerating || _recordFilePath == null)
//                 ? null
//                 : () => _generateVideo(type: "audio"),
//             child: const Text("Generate from Voice"),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPreview(ColorScheme cs) {
//     if (_isGenerating) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 12),
//             Text("Generating... ${(_progress * 100).toInt()}%"),
//           ],
//         ),
//       );
//     }
//
//     if (_videoFilePath == null) {
//       return Center(
//         child: Text(
//           "No video yet.\nGenerate using Text or Voice",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 16,
//             color: cs.onSurfaceVariant,
//           ),
//         ),
//       );
//     }
//
//     return GestureDetector(
//       onTap: _openFile,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: cs.surfaceVariant,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: const [
//             Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
//             SizedBox(height: 12),
//             Text(
//               "Tap to Play Generated Video",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
