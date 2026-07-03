import 'package:chat_demo/import.dart';

class SPUtil {
  // 单例模式
  static SPUtil? _instance;
  static SharedPreferences? _prefs;

  // 私有化构造函数
  SPUtil._();

  // 获取单例
  static Future<SPUtil> getInstance() async {
    _instance ??= SPUtil._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // 初始化
  static Future<void> init() async {  
    await StorageManage.getToken();
    await StorageManage.getUserId();
    await StorageManage.getUserSig();
    await StorageManage.getMeModel();
    await StorageManage.getChatList();
  }

  // ========== 定义存储的key（统一管理，避免拼写错误） ==========
  static const String KEY_USER_TOKEN = "user_token";
  static const String KEY_USER_ID = "user_id";
  static const String KEY_USER_SIG = "user_sig";
  static const String KEY_ME_MODEL = "me_model";
  static const String KEY_CHAT_LIST = "chat_list";

  // ========== 封装常用方法 ==========
  // 保存字符串
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  // 读取字符串
  String getString(String key, {String defaultValue = ""}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // 保存布尔值
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // 读取布尔值
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // 删除单个key
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  // 清空所有数据
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
