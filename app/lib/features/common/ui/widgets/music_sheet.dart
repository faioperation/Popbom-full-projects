import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicSheetAPI extends StatefulWidget {
  final List<Map<String, dynamic>> results;
  final Function(String) onSearch;
  final Function(Map<String, dynamic>) onSelect;
  final String selectedUrl;

  const MusicSheetAPI({
    Key? key,
    required this.results,
    required this.onSearch,
    required this.onSelect,
    required this.selectedUrl,
  }) : super(key: key);

  @override
  State<MusicSheetAPI> createState() => _MusicSheetAPIState();
}

class _MusicSheetAPIState extends State<MusicSheetAPI> {
  final TextEditingController _searchController = TextEditingController();

  final AudioPlayer _player = AudioPlayer();
  Timer? _debounce;

  String _selectedUrl = "";
  String _playingUrl = "";
  bool _isPlaying = false;
  bool _loadingAudio = false;

  List<Map<String, dynamic>> _local = [];

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.selectedUrl;
    _local = widget.results;

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingUrl = "";
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant MusicSheetAPI oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sync provided list and selectedUrl
    if (widget.results != oldWidget.results) {
      setState(() => _local = widget.results);
    }
    if (widget.selectedUrl != oldWidget.selectedUrl) {
      setState(() => _selectedUrl = widget.selectedUrl);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _playPause(String url) async {
    if (url.isEmpty) {
      debugPrint("❌ NO valid mp3 url");
      return;
    }

    // ✅ New fix here
    if (!url.toLowerCase().endsWith(".mp3")) {
      debugPrint("❌ Not an mp3 url, skipping audio preview");
      return;
    }

    setState(() => _loadingAudio = true);

    try {
      if (_playingUrl == url && _isPlaying) {
        await _player.pause();
        setState(() {
          _isPlaying = false;
          _loadingAudio = false;
        });
        return;
      }

      await _player.stop();

      // ⚠️ This was causing the crash for non-mp3 URLs
      await _player.setUrl(url);

      await _player.play();

      setState(() {
        _playingUrl = url;
        _isPlaying = true;
        _loadingAudio = false;
      });
    } catch (e) {
      debugPrint("❌ AUDIO ERROR: $e");
      setState(() => _loadingAudio = false);
    }
  }



  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(q);
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() => _local = widget.results);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, color: Colors.grey),
          const SizedBox(height: 12),
          if (_selectedUrl.isNotEmpty)
            Row(
              children: [
                const SizedBox(width: 16),
                const Text("Preview"),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    (_playingUrl == _selectedUrl && _isPlaying)
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.green,
                    size: 35,
                  ),
                  onPressed: () => _playPause(_selectedUrl),
                )
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                  hintText: "Search music...", prefixIcon: Icon(Icons.search)),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _local.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = _local[i];
                final url = m["external_url"]?.toString() ?? "";
                final name = m["name"]?.toString() ?? "";
                final artists = (m["artists"] is List)
                    ? (m["artists"] as List).join(", ")
                    : (m["artists"]?.toString() ?? "");

                final isSelected = url == _selectedUrl;
                final isPlaying = url == _playingUrl && _isPlaying;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (m["thumbnail"] != null) ? NetworkImage(m["thumbnail"]) : null,
                    child: m["thumbnail"] == null ? const Icon(Icons.music_note) : null,
                  ),
                  title: Text(name),
                  subtitle: Text(artists),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_loadingAudio && _playingUrl == url)
                        const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      if (!(_loadingAudio && _playingUrl == url))
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            size: 30,
                            color: isPlaying ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _playPause(url),
                        ),
                      if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  onTap: () {
                    setState(() => _selectedUrl = url);
                    widget.onSelect(m);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
