import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/app/app.dart';
import 'package:popbom/core/services/local_notification_service.dart';
import 'package:popbom/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs, permanent: true);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PopBom(),
    ),
  );
}
