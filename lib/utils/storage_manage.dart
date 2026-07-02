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

  /// 设置好友列表
  static Future<void> setFriendsList(List<FriendModel> value) async {
    UserPro.friendsList = value;
    final sp = await SPUtil.getInstance();
    final model = FriendsListModel(list: value);
    await sp.setString(SPUtil.KEY_FRIENDS_LIST, jsonEncode(model.toJson()));
  }

  /// 获取好友列表
  static Future<List<FriendModel>> getFriendsList() async {
    final sp = await SPUtil.getInstance();
    final json = sp.getString(SPUtil.KEY_FRIENDS_LIST);
    if (json.isEmpty) {
      UserPro.friendsList = [];
      return [];
    }
    UserPro.friendsList =
        FriendsListModel.fromJson(jsonDecode(json) as Map<String, dynamic>).list;
    return UserPro.friendsList;
  }
}
