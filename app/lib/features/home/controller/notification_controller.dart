import 'package:get/get.dart';
import 'package:popbom/features/home/model/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class NotificationController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();

  final RxBool loading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  static const _readKey = 'read_notification_ids';

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  /// 🔹 Load saved read IDs
  Future<Set<String>> _getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_readKey)?.toSet() ?? {};
  }

  /// 🔹 Save read IDs
  Future<void> _saveReadIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readKey, ids.toList());
  }

  Future<void> fetchNotifications(String userId) async {
    loading.value = true;

    try {
      final readIds = await _getReadIds();
      final res =
      await _client.getRequest(Urls.getUserNotifications(userId));

      if (!res.isSuccess) {
        notifications.clear();
        return;
      }

      final List list = res.responseData!['data'];

      notifications.value = list.map((e) {
        final n = NotificationModel.fromJson(e);
        if (readIds.contains(n.id)) {
          n.isRead = true;
        }
        return n;
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } finally {
      loading.value = false;
    }
  }

  /// ✅ Mark all as read (persistent)
  Future<void> markAllAsRead() async {
    final readIds = await _getReadIds();

    for (final n in notifications) {
      n.isRead = true;
      readIds.add(n.id);
    }

    await _saveReadIds(readIds);
    notifications.refresh();
  }
}




///push notification
///import 'package:get/get.dart';
// import 'package:popbom/core/services/local_notification_service.dart';
// import 'package:popbom/features/home/model/notification_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:popbom/app/urls.dart';
// import 'package:popbom/core/services/network/network_client.dart';
//
// class NotificationController extends GetxController {
//   final NetworkClient _client = Get.find<NetworkClient>();
//
//   final RxBool loading = false.obs;
//   final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
//
//   static const _readKey = 'read_notification_ids';
//
//   int get unreadCount =>
//       notifications.where((n) => !n.isRead).length;
//
//   Future<Set<String>> _getReadIds() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getStringList(_readKey)?.toSet() ?? {};
//   }
//
//   Future<void> _saveReadIds(Set<String> ids) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList(_readKey, ids.toList());
//   }
//
//   Future<void> fetchNotifications(String userId) async {
//     loading.value = true;
//
//     try {
//       final readIds = await _getReadIds();
//       final res =
//       await _client.getRequest(Urls.getUserNotifications(userId));
//
//       if (!res.isSuccess) {
//         notifications.clear();
//         return;
//       }
//
//       final List list = res.responseData!['data'];
//
//       final newNotifications = list.map((e) {
//         final n = NotificationModel.fromJson(e);
//         if (readIds.contains(n.id)) {
//           n.isRead = true;
//         }
//         return n;
//       }).toList()
//         ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
//
//       final oldUnread = notifications.where((n) => !n.isRead).length;
//       final newUnread =
//           newNotifications.where((n) => !n.isRead).length;
//
//       notifications.value = newNotifications;
//
//       if (newUnread > oldUnread && newNotifications.isNotEmpty) {
//         final latest = newNotifications.first;
//
//         await LocalNotificationService.showNotification(
//           title: latest.senderName,
//           body: latest.message,
//           id: latest.hashCode,
//         );
//       }
//     } finally {
//       loading.value = false;
//     }
//   }
//
//
//   Future<void> markAllAsRead() async {
//     final readIds = await _getReadIds();
//
//     for (final n in notifications) {
//       n.isRead = true;
//       readIds.add(n.id);
//     }
//
//     await _saveReadIds(readIds);
//     notifications.refresh();
//   }
// }