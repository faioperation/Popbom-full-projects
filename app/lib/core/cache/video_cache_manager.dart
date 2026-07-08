import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCacheManager extends CacheManager {
  static const String _key = 'videoCache';

  static final VideoCacheManager _instance =
  VideoCacheManager._internal();

  factory VideoCacheManager() {
    return _instance;
  }

  VideoCacheManager._internal()
      : super(
    Config(
      _key,
      stalePeriod: const Duration(days: 2),
      maxNrOfCacheObjects: 15, // short videos only
      repo: JsonCacheInfoRepository(databaseName: _key),
      fileService: HttpFileService(),
    ),
  );
}
