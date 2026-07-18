import 'package:chat_demo/model/chat_list_model.dart';
import 'package:chat_demo/model/friend_list_model.dart';
import 'package:chat_demo/model/friend_request_model.dart';
import 'package:chat_demo/model/me_model.dart';
import 'package:chat_demo/model/notification_model.dart';
import 'package:flutter/foundation.dart';

/// 全局 Provider 引用（无 context 的工具类用）
class AppProviders {
  static late AuthProvider auth;
  static late ChatProvider chat;
  static late ContactProvider contact;

  static void bind({
    required AuthProvider auth,
    required ChatProvider chat,
    required ContactProvider contact,
  }) {
    AppProviders.auth = auth;
    AppProviders.chat = chat;
    AppProviders.contact = contact;
  }
}

/// 登录态 / 我的资料
class AuthProvider extends ChangeNotifier {
  String token = '';
  String userId = '';
  String userSig = '';
  MeModel? meModel;

  void setToken(String value) {
    if (token == value) return;
    token = value;
    notifyListeners();
  }

  void setUserId(String value) {
    if (userId == value) return;
    userId = value;
    notifyListeners();
  }

  void setUserSig(String value) {
    if (userSig == value) return;
    userSig = value;
    notifyListeners();
  }

  void setMeModel(MeModel? value) {
    meModel = value;
    notifyListeners();
  }

  void clear() {
    token = '';
    userId = '';
    userSig = '';
    meModel = null;
    notifyListeners();
  }
}

/// 会话列表 + IM 未读
class ChatProvider extends ChangeNotifier {
  List<ChatModel> chatList = [];
  int unreadCount = 0;
  Map<String, int> conversationUnread = {};

  void setChatList(List<ChatModel> list) {
    chatList = list;
    notifyListeners();
  }

  void setUnreadCount(int count) {
    if (unreadCount == count) return;
    unreadCount = count;
    notifyListeners();
  }

  void setConversationUnread(Map<String, int> map) {
    conversationUnread = Map<String, int>.from(map);
    notifyListeners();
  }

  void removeConversationUnread(String conversationID) {
    if (!conversationUnread.containsKey(conversationID)) return;
    final map = Map<String, int>.from(conversationUnread)
      ..remove(conversationID);
    conversationUnread = map;
    notifyListeners();
  }

  int unreadOf(String? conversationID) {
    if (conversationID == null || conversationID.isEmpty) return 0;
    return conversationUnread[conversationID] ?? 0;
  }

  void clear() {
    chatList = [];
    unreadCount = 0;
    conversationUnread = {};
    notifyListeners();
  }
}

/// 好友 / 申请 / 通知
class ContactProvider extends ChangeNotifier {
  List<FriendModel> friendList = [];
  List<FriendRequestModel> friendRequests = [];
  int friendRequestUnread = 0;
  List<NotificationModel> notifications = [];
  int notificationUnread = 0;

  int get addressUnread => friendRequestUnread + notificationUnread;

  void setFriendList(List<FriendModel> list) {
    friendList = list;
    notifyListeners();
  }

  void setFriendRequests(List<FriendRequestModel> list) {
    friendRequests = list;
    notifyListeners();
  }

  void setFriendRequestUnread(int count) {
    if (friendRequestUnread == count) return;
    friendRequestUnread = count;
    notifyListeners();
  }

  void setNotifications(List<NotificationModel> list) {
    notifications = list;
    notifyListeners();
  }

  void setNotificationUnread(int count) {
    if (notificationUnread == count) return;
    notificationUnread = count;
    notifyListeners();
  }

  void clear() {
    friendList = [];
    friendRequests = [];
    friendRequestUnread = 0;
    notifications = [];
    notificationUnread = 0;
    notifyListeners();
  }
}
