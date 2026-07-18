import 'package:chat_demo/utils/app_provider.dart';
import 'package:chat_demo/model/chat_list_model.dart';
import 'package:chat_demo/model/friend_list_model.dart';
import 'package:chat_demo/model/me_model.dart';

/// 兼容旧代码：读写转发到 Provider
class UserPro {
  static String get token => AppProviders.auth.token;
  static set token(String value) => AppProviders.auth.setToken(value);

  static String get userId => AppProviders.auth.userId;
  static set userId(String value) => AppProviders.auth.setUserId(value);

  static String get userSig => AppProviders.auth.userSig;
  static set userSig(String value) => AppProviders.auth.setUserSig(value);

  static MeModel? get meModel => AppProviders.auth.meModel;
  static set meModel(MeModel? value) => AppProviders.auth.setMeModel(value);

  static List<ChatModel> get chatList => AppProviders.chat.chatList;
  static set chatList(List<ChatModel> value) =>
      AppProviders.chat.setChatList(value);

  static List<FriendModel> get friendList => AppProviders.contact.friendList;
  static set friendList(List<FriendModel> value) =>
      AppProviders.contact.setFriendList(value);
}
