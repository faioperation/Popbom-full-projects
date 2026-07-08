import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/chat/model/socket.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final String _userDataKey = "user-data";
  final String _tokenKey = "access-token";
  final String _userIdKey = "user-id";

  final String _rememberMeKey = "remember-me";
  final String _rememberEmailKey = "remember-email";
  final String _rememberPasswordKey = "remember-password";
  
  SharedPreferences? _prefs;
  Future<SharedPreferences> get prefs async => _prefs ??= await SharedPreferences.getInstance();


  UserModel? userModel;
  String? accessToken;
  String? userId;


  final String _refreshTokenKey = "refresh-token";

  String? refreshToken;

  Future<void> saveRememberMe({
    required bool remember,
    String? email,
    String? password,
  }) async {
    final p = await prefs;
    await p.setBool(_rememberMeKey, remember);

    if (remember) {
      if (email != null) {
        await p.setString(_rememberEmailKey, email);
      }
      if (password != null) {
        await p.setString(_rememberPasswordKey, password);
      }
    } else {
      await p.remove(_rememberEmailKey);
      await p.remove(_rememberPasswordKey);
    }
  }


  Future<(bool, String?, String?)> getRememberMe() async {
    final p = await prefs;
    final remember = p.getBool(_rememberMeKey) ?? false;
    final email = p.getString(_rememberEmailKey);
    final password = p.getString(_rememberPasswordKey);

    return (remember, email, password);
  }


  /// SAVE USER + TOKEN + USERID
  Future<void> saveUserData(
      String? token,
      UserModel model, {
        String? refreshToken,
      }) async {
    final p = await prefs;
    // Save user model
    await p.setString(_userDataKey, jsonEncode(model.toJson()));
    // Save access token
    if (token != null && token.isNotEmpty) {
      await p.setString(_tokenKey, token);
      accessToken = token;

      try {
        final decoded = JwtDecoder.decode(token);
        userId = decoded["userId"]?.toString();

        if (userId != null) {
          await p.setString(_userIdKey, userId!);
        }
      } catch (_) {}
    }

    // 🔥 NEW: Save refresh token (optional)
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await p.setString(_refreshTokenKey, refreshToken);
      this.refreshToken = refreshToken;
    }

    userModel = model;
  }


  /// GET USER DATA FROM LOCAL
  Future<void> getUserData() async {
    final p = await prefs;
    final userData = p.getString(_userDataKey);
    final tokenData = p.getString(_tokenKey);
    final uidData = p.getString(_userIdKey);
    final refreshTokenData = p.getString(_refreshTokenKey); // 🔥 NEW

    if (userData != null) {
      userModel = UserModel.fromJson(jsonDecode(userData));
    }

    accessToken = tokenData;
    userId = uidData;
    refreshToken = refreshTokenData; // 🔥 NEW
  }


  /// CHECK LOGIN
  Future<bool> isUserLoggedIn() async {
    final p = await prefs;
    String? tokenData = p.getString(_tokenKey);

    print("🔍 isUserLoggedIn(): token=$tokenData");

    if (tokenData != null) {
      await getUserData();
      return true;
    } else {
      return false;
    }
  }

  /// LOGOUT
  Future<void> clearUserData() async {
    final p = await prefs;
    await p.remove(_tokenKey);
    await p.remove(_refreshTokenKey);
    await p.remove(_userDataKey);
    await p.remove(_userIdKey);

    accessToken = null;
    refreshToken = null;
    userModel = null;
    userId = null;

    // 🔥 Fix: Ensure socket is disconnected on logout
    try {
      SocketService.dispose();
    } catch (_) {}
  }

}
