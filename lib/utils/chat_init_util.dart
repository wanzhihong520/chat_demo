import 'package:chat_demo/import.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_status.dart';

class ChatInitUtil {
  // 1. 从即时通信 IM 控制台获取应用 SDKAppID。
  int sdkAppID = 1600148870;
  
  Future<void> initSDK() async {
    // 2. 添加 V2TimSDKListener 的事件监听器，sdkListener 是 V2TimSDKListener 的实现类
    V2TimSDKListener sdkListener = V2TimSDKListener(
      onConnectFailed: (int code, String error) {
        // 连接失败的回调函数
        // code 错误码
        // error 错误信息
        if (kDebugMode) {
          print('连接失败: $code, $error');
        }
      },
      onConnectSuccess: () {
        // SDK 已经成功连接到腾讯云服务器
        if (kDebugMode) {
          print('连接成功');
        }
      },
      onConnecting: () {
        // SDK 正在连接到腾讯云服务器
        if (kDebugMode) {
          print('连接中');
        }
      },
      onKickedOffline: () {
        // 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
        if (kDebugMode) {
          print('当前用户被踢下线');
        }
      },
      onSelfInfoUpdated: (V2TimUserFullInfo info) {
        // 登录用户的资料发生了更新
        // info登录用户的资料
        if (kDebugMode) {
          print('登录用户的资料发生了更新: $info');
        }
      },
      onUserSigExpired: () {
        // 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
        if (kDebugMode) {
          print('在线时票据过期');
        }
      },
      onUserStatusChanged: (List<V2TimUserStatus> userStatusList) {
        //用户状态变更通知
        //userStatusList 用户状态变化的用户列表
        //收到通知的情况：订阅过的用户发生了状态变更（包括在线状态和自定义状态），会触发该回调
        //在 IM 控制台打开了好友状态通知开关，即使未主动订阅，当好友状态发生变更时，也会触发该回调
        //同一个账号多设备登录，当其中一台设备修改了自定义状态，所有设备都会收到该回调
        if (kDebugMode) {
          print('用户状态变更通知: $userStatusList');
        }
      },
    );

    // 3.初始化SDK
    V2TimValueCallback<bool> initSDKRes = await TencentImSDKPlugin.v2TIMManager
        .initSDK(
          sdkAppID: sdkAppID, // SDKAppID
          loglevel: LogLevelEnum.V2TIM_LOG_ALL, // 日志登记等级
          listener: sdkListener, // 事件监听器
        );
    if (initSDKRes.code == 0) {
      //初始化成功
      if (kDebugMode) {
        print('初始化成功');
      }
    }
  }
}
