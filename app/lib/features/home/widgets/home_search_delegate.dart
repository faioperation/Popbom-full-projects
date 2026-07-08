import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/home/controller/visual_search_controller.dart';
import 'package:popbom/features/home/services/voice_record_service.dart';
import 'package:popbom/features/home/ui/screen/visual_search_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeSearchDelegate extends SearchDelegate<String> {

  final VoiceRecordService _voiceService = VoiceRecordService();

  // Voice Search instances
  final RxBool _isListening = false.obs;

  // Image Search instances
  final ImagePicker _imagePicker = ImagePicker();

  HomeSearchDelegate() {
    if (!Get.isRegistered<VisualSearchController>()) {
      Get.put(VisualSearchController(), permanent: false);
    }

    // _speech = stt.SpeechToText();
    // _initializeSpeech();
  }


  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎤 VOICE SEARCH INITIALIZATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Future<void> _initializeSpeech() async {
  //   try {
  //     await _speech.initialize(
  //       onError: (error) {
  //         print('❌ Speech error: ${error.errorMsg}');
  //         _isListening.value = false;
  //       },
  //       onStatus: (status) {
  //         print('🔵 Speech status: $status');
  //         if (status == 'done' || status == 'notListening') {
  //           _isListening.value = false;
  //         }
  //       },
  //     );
  //     print('✅ Speech initialized: ${_speech.isAvailable}');
  //   } catch (e) {
  //     print('❌ Speech init error: $e');
  //   }
  // }

  @override
  String? get searchFieldLabel => 'Search reels, posts...';

  @override
  TextStyle? get searchFieldStyle => null;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    final cs = base.colorScheme;
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: cs.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: base.appBarTheme.foregroundColor ?? cs.onBackground,
        ),
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          color: base.appBarTheme.foregroundColor ?? cs.onBackground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: base.textTheme.bodyMedium?.copyWith(
          color: cs.onSurface.withOpacity(0.6),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: cs.onBackground),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [
      // 🎤 Voice Search Button
      Obx(() => IconButton(
        icon: Icon(
          _isListening.value ? Icons.mic : Icons.mic_none,
          color: _isListening.value ? Colors.red : cs.onBackground,
        ),
        onPressed: () => _handleVoiceSearch(context),
        tooltip: 'Voice Search',
      )),

      // 📷 Image Search Button
      IconButton(
        icon: Icon(Icons.image_search, color: cs.onBackground),
        onPressed: () => _showImageSearchOptions(context),
        tooltip: 'Search by Image',
      ),

      // ❌ Clear Button
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: cs.onBackground),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, color: cs.onBackground),
      onPressed: () {
        _cleanUp();
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final ctrl = Get.find<VisualSearchController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.trim().isNotEmpty) {
        ctrl.searchByText(query);
      }
    });

    return const VisualSearchResultScreen();
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }


  Future<void> _handleVoiceSearch(BuildContext context) async {
    if (_isListening.value) return;

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _showPermissionDialog(context, 'Microphone');
      return;
    }

    _isListening.value = true;

    _showVoiceSearchDialog(context);

    await Future.delayed(const Duration(milliseconds: 300));
    final File? startedFile = await _voiceService.start();
    if (startedFile == null) {
      _isListening.value = false;
      Navigator.of(context).pop();
      _showSnackBar(context, 'Failed to start recording');
      return;
    }

    // ⏱ Auto stop after 6 seconds
    await Future.delayed(const Duration(seconds: 6));
    if (!_isListening.value) return;

    final File? audioFile = await _voiceService.stop();
    _isListening.value = false;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (audioFile == null) {
      _showSnackBar(context, 'No audio recorded');
      return;
    }

    print('🎤 Audio file: ${audioFile.path}');
    print('🎤 Size: ${await audioFile.length()} bytes');

    final ctrl = Get.find<VisualSearchController>();

    await ctrl.searchByVoice(audioFile);

    if (ctrl.results.isEmpty) {
      _showSnackBar(context, 'No results found');
      return;
    }

    close(context, '');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VisualSearchResultScreen(),
      ),
    );
  }

  void _showVoiceSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async {
          _isListening.value = false;
          await _voiceService.stop();
          return true;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isListening.value
                      ? Colors.red.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mic,
                  size: 50,
                  color: _isListening.value ? Colors.red : Colors.grey,
                ),
              )),
              const SizedBox(height: 20),
              const Text(
                'Listening...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () async {
                  _isListening.value = false;
                  await _voiceService.stop();
                  if (Navigator.of(ctx).canPop()) {
                    Navigator.of(ctx).pop();
                  }
                },
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📷 IMAGE SEARCH HANDLER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _showImageSearchOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Search by Image',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Camera Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Capture with camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ImageSource.camera);
                },
              ),

              // Gallery Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Select existing photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ImageSource.gallery);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {

    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showPermissionDialog(context, 'Camera');
        return;
      }
    }

    if (source == ImageSource.gallery) {
      PermissionStatus status;

      if (Platform.isAndroid) {
        status = await Permission.photos.request(); // ✅ Android 13+
      } else {
        status = await Permission.photos.request(); // iOS
      }

      if (!status.isGranted) {
        _showPermissionDialog(context, 'Gallery');
        return;
      }
    }

    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );

    if (image == null) return;

    _showLoadingDialog(context, 'Searching...');
    await _processImage(context, image.path);
  }


  Future<void> _processImage(BuildContext context, String imagePath) async {
    final ctrl = Get.find<VisualSearchController>();
    final navigator = Navigator.of(context);

    final file = File(imagePath);

    print('📂 Image path: $imagePath');
    print('📂 Exists: ${await file.exists()}');

    if (!await file.exists()) {
      if (navigator.canPop()) navigator.pop();
      _showSnackBar(context, 'Invalid image file');
      return;
    }

    await ctrl.searchByImage(file);

    if (navigator.canPop()) navigator.pop();

    if (ctrl.results.isEmpty) {
      _showSnackBar(context, 'No results found');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VisualSearchResultScreen(),
      ),
    );
  }


  List<String> _extractSearchTerms(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'));

    final terms = <String>{};

    for (var word in words) {
      if (word.length >= 3) {
        terms.add(word);
      }
    }

    return terms.take(8).toList();
  }

  void _showExtractedTerms(BuildContext context, List<String> terms) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found in image:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: terms.map((term) {
                  return ActionChip(
                    label: Text(term),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () {
                      Navigator.pop(ctx);
                      query = term;
                      showResults(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎨 UI COMPONENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━



  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$permissionName Permission'),
        content: Text(
          'This feature requires $permissionName permission. Please grant permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cleanUp() {
    //_speech.cancel();
    _isListening.value = false;
  }
}