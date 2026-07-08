import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'network_response.dart';

dynamic _parseJson(String text) => jsonDecode(text);

Future<dynamic> _safeJsonDecode(String body) async {
  try {
    return await compute(_parseJson, body);
  } catch (e) {
    // Fallback to synchronous decode if isolate parsing fails
    return jsonDecode(body);
  }
}

class NetworkClient {
  final Logger _logger = Logger();
  final String _defaultErrorMassage = 'Something went wrong';

  final VoidCallback onUnAuthorize;
  final Map<String, String> Function() commonHeaders;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  NetworkClient({required this.onUnAuthorize, required this.commonHeaders});

  Future<NetworkResponse> getRequest(
    String url, {
    bool retried = false,
    bool fromCache = false,
  }) async {
    try {
      if (fromCache) {
        final cachedData = _getCache(url);
        if (cachedData != null) {
          return NetworkResponse(
            isSuccess: true,
            statusCode: 200,
            responseData: cachedData,
          );
        }
        // If cache requested but empty, return error or proceed to network?
        // Current design: fromCache means ONLY cache.
        return NetworkResponse(
          isSuccess: false,
          statusCode: -1,
          errorMassage: "No cached data found",
        );
      }

      final uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders());

      final response = await http.get(uri, headers: commonHeaders());
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = await _safeJsonDecode(response.body);
        _saveCache(url, data); // Save to cache

        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: data,
        );
      }

      if (response.statusCode == 401 && !retried) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return getRequest(url, retried: true);
        } else {
          onUnAuthorize();
        }
      }

      final body = await _safeJsonDecode(response.body);
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMassage: body['message'] ?? _defaultErrorMassage,
      );
    } catch (e) {
      // Offline fallback: try to load cache if network failed
      final cachedData = _getCache(url);
      if (cachedData != null) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: 200,
          responseData: cachedData,
        );
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMassage: e.toString(),
      );
    }
  }

  // --- Cache Helpers ---
  void _saveCache(String url, dynamic data) {
    try {
      _prefs.setString('CACHE_$url', jsonEncode(data));
    } catch (e) {
      if (kDebugMode) print("Cache Save Error: $e");
    }
  }

  dynamic _getCache(String url) {
    try {
      final String? raw = _prefs.getString('CACHE_$url');
      if (raw != null) {
        return jsonDecode(raw);
      }
    } catch (e) {
      if (kDebugMode) print("Cache Read Error: $e");
    }
    return null;
  }

  Future<NetworkResponse> postRequest(
    String url, {
    Map<String, dynamic>? body,
    bool retried = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders(), body: body);

      final response = await http.post(
        uri,
        headers: commonHeaders(),
        body: jsonEncode(body ?? {}),
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: await _safeJsonDecode(response.body),
        );
      }

      if (response.statusCode == 401 && !retried) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return postRequest(url, body: body, retried: true);
        } else {
          onUnAuthorize();
        }
      }

      final bodyRes = await _safeJsonDecode(response.body);
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMassage: bodyRes['message'] ?? _defaultErrorMassage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMassage: e.toString(),
      );
    }
  }

  Future<NetworkResponse> putRequest(
    String url, {
    Map<String, dynamic>? body,
    bool retried = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders(), body: body);

      final response = await http.put(
        uri,
        headers: commonHeaders(),
        body: jsonEncode(body ?? {}),
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: await _safeJsonDecode(response.body),
        );
      }

      if (response.statusCode == 401 && !retried) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return putRequest(url, body: body, retried: true);
        } else {
          onUnAuthorize();
        }
      }

      final bodyRes = await _safeJsonDecode(response.body);
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMassage: bodyRes['message'] ?? _defaultErrorMassage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMassage: e.toString(),
      );
    }
  }

  Future<NetworkResponse> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    bool retried = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders(), body: body);

      final response = await http.patch(
        uri,
        headers: commonHeaders(),
        body: jsonEncode(body ?? {}),
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: await _safeJsonDecode(response.body),
        );
      }

      if (response.statusCode == 401 && !retried) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return patchRequest(url, body: body, retried: true);
        } else {
          onUnAuthorize();
        }
      }

      final bodyRes = await _safeJsonDecode(response.body);
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMassage: bodyRes['message'] ?? _defaultErrorMassage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMassage: e.toString(),
      );
    }
  }

  Future<NetworkResponse> deleteRequest(
    String url, {
    Map<String, dynamic>? body,
    bool retried = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      _logRequest(url, headers: commonHeaders(), body: body);

      final response = await http.delete(
        uri,
        headers: commonHeaders(),
        body: jsonEncode(body ?? {}),
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: await _safeJsonDecode(response.body),
        );
      }

      if (response.statusCode == 401 && !retried) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return deleteRequest(url, body: body, retried: true);
        } else {
          onUnAuthorize();
        }
      }

      final bodyRes = await _safeJsonDecode(response.body);
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMassage: bodyRes['message'] ?? _defaultErrorMassage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMassage: e.toString(),
      );
    }
  }

  Future<NetworkResponse> multipartRequest(
    String url, {
    required Map<String, String> fields,
    Map<String, File>? files,
    String method = 'POST',
    bool retried = false,
  }) async {
    try {
      final uri = Uri.parse(url);

      final headers = Map<String, String>.from(commonHeaders());
      headers.remove('Content-Type');

      _logRequest(url, headers: headers, body: fields);

      final request = http.MultipartRequest(method, uri);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          final parts = mimeType.split('/');

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              contentType: http.MediaType(parts[0], parts[1]),
            ),
          );
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: await _safeJsonDecode(response.body),
        );
      }

      if (response.statusCode == 401 && !retried) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return multipartRequest(
            url,
            fields: fields,
            files: files,
            method: method,
            retried: true,
          );
        } else {
          onUnAuthorize();
        }
      }

      final bodyRes = await _safeJsonDecode(response.body);
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMassage: bodyRes['message'] ?? _defaultErrorMassage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMassage: e.toString(),
      );
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    final auth = Get.find<AuthController>();
    final refreshToken = auth.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      _isRefreshing = false;
      _refreshCompleter!.complete(false);
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(Urls.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = await _safeJsonDecode(response.body);
        final data = body['data'];

        if (data != null && data['accessToken'] != null) {
          await auth.saveUserData(
            data['accessToken'],
            auth.userModel!,
            refreshToken: data['refreshToken'],
          );
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _logRequest(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    // Disable logging in Release Mode to save performance
    if (const bool.fromEnvironment('dart.vm.product')) return;

    final bodyStr = jsonEncode(body ?? {});
    // Truncate long bodies for lighter logging
    final prettyBody = bodyStr.length > 500
        ? '${bodyStr.substring(0, 500)}... (truncated)'
        : bodyStr;

    _logger.i('''
💡 REQUEST
URL -> $url
HEADERS -> $headers
BODY -> $prettyBody
''');
  }

  void _logResponse(http.Response response) {
    // Disable logging in Release Mode to save performance
    if (const bool.fromEnvironment('dart.vm.product')) return;

    final bodyStr = response.body;
    // Truncate long bodies
    final prettyBody = bodyStr.length > 500
        ? '${bodyStr.substring(0, 500)}... (truncated)'
        : bodyStr;

    _logger.i('''
💡 RESPONSE
URL -> ${response.request?.url}
STATUS CODE -> ${response.statusCode}
BODY -> $prettyBody
''');
  }
}
