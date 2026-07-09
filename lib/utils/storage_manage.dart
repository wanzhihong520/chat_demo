import 'package:chat_demo/import.dart';

class StorageManage {
  /// 设置token
  static Future<void> setToken(String value) async {
    UserPro.token = value;
    final sp = await SPUtil.getInstance();
    await sp.setString(SPUtil.KEY_USER_TOKEN, value);
  }

  /// 获取token
  static Future<String> getToken() async {
    final sp = await SPUtil.getInstance();
    UserPro.token = sp.getString(SPUtil.KEY_USER_TOKEN);
    return UserPro.token;
  }

  /// 设置userId
  static Future<void> setUserId(String value) async {
    UserPro.userId = value;
    final sp = await SPUtil.getInstance();
    await sp.setString(SPUtil.KEY_USER_ID, value);
  }

  /// 获取userId
  static Future<String> getUserId() async {
    final sp = await SPUtil.getInstance();
    UserPro.userId = sp.getString(SPUtil.KEY_USER_ID);
    return UserPro.userId;
  }

  /// 设置userSig
  static Future<void> setUserSig(String value) async {
    UserPro.userSig = value;
    final sp = await SPUtil.getInstance();
    await sp.setString(SPUtil.KEY_USER_SIG, value);
  }

  /// 获取userSig
  static Future<String> getUserSig() async {
    final sp = await SPUtil.getInstance();
    UserPro.userSig = sp.getString(SPUtil.KEY_USER_SIG);
    return UserPro.userSig;
  }

  /// 设置meModel
  static Future<void> setMeModel(MeModel value) async {
    UserPro.meModel = value;
    final sp = await SPUtil.getInstance();
    await sp.setString(SPUtil.KEY_ME_MODEL, jsonEncode(value.toJson()));
  }

  /// 获取meModel
  static Future<MeModel?> getMeModel() async {
    final sp = await SPUtil.getInstance();
    final meModel = sp.getString(SPUtil.KEY_ME_MODEL);
    if (meModel.isEmpty) {
      UserPro.meModel = null;
      return null;
    }
    UserPro.meModel = MeModel.fromJson(jsonDecode(meModel));
    return UserPro.meModel;
  }

  /// 设置聊天列表
  static Future<void> setChatList(List<ChatModel> value) async {
    UserPro.chatList = value;
    final sp = await SPUtil.getInstance();
    final model = ChatListModel(list: value);
    await sp.setString(SPUtil.KEY_CHAT_LIST, jsonEncode(model.toJson()));
  }

  /// 获取聊天列表
  static Future<List<ChatModel>> getChatList() async {
    final sp = await SPUtil.getInstance();
    final json = sp.getString(SPUtil.KEY_CHAT_LIST);
    if (json.isEmpty) {
      UserPro.chatList = [];
      return [];
    }
    UserPro.chatList =
        ChatListModel.fromJson(jsonDecode(json) as Map<String, dynamic>).list;
    return UserPro.chatList;
  }

  /// 设置好友列表
  static Future<void> setFriendList(List<FriendModel> value) async {
    UserPro.friendList = value;
    final sp = await SPUtil.getInstance();
    final model = FriendListModel(list: value);
    await sp.setString(SPUtil.KEY_FRIEND_LIST, jsonEncode(model.toJson()));
  }

  /// 获取好友列表
  static Future<List<FriendModel>> getFriendList() async {
    final sp = await SPUtil.getInstance();
    final json = sp.getString(SPUtil.KEY_FRIEND_LIST);
    if (json.isEmpty) {
      UserPro.friendList = [];
      return [];
    }
    UserPro.friendList =
        FriendListModel.fromJson(jsonDecode(json) as Map<String, dynamic>).list;
    return UserPro.friendList;
  }
}
