import 'package:chat_demo/import.dart';

class ChatUtil {
  static final chatListNotifier = ValueNotifier<List<ChatModel>>([]);
  static final friendListNotifier = ValueNotifier<List<FriendModel>>([]);

  static V2TimAdvancedMsgListener? _msgListener;
  static void Function(V2TimMessage message)? onNewMessage;

  /// 拉取会话列表并更新本地
  static Future<List<ChatModel>> fetchChatList() async {
    final response = await Api().get('/api/chat/list');
    if (response.statusCode != 200 || response.data is! Map) {
      return UserPro.chatList;
    }
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] is! Map) {
      return UserPro.chatList;
    }
    final list = ChatListModel.fromJson(
      body['data'] as Map<String, dynamic>,
    ).list;
    await StorageManage.setChatList(list);
    chatListNotifier.value = list;
    return list;
  }

  /// 拉取好友列表并更新本地
  static Future<List<FriendModel>> fetchFriendList() async {
    final response = await Api().get('/api/friends');
    if (response.statusCode != 200 || response.data is! Map) {
      return UserPro.friendList;
    }
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] is! Map) {
      return UserPro.friendList;
    }
    final list = FriendListModel.fromJson(
      body['data'] as Map<String, dynamic>,
    ).list;
    await StorageManage.setFriendList(list);
    friendListNotifier.value = list;
    return list;
  }

  static String messagePreview(V2TimMessage message) {
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return message.textElem?.text ?? '';
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return '图片';
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return '视频';
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return message.fileElem?.fileName ?? '文件';
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return '语音';
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return '表情';
      default:
        return '';
    }
  }

  /// 发送单聊消息（createXxxMessage 拿到 id 后调用）
  static Future<V2TimMessage?> sendToC2C({
    required String id,
    required String receiver,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessage(
          id: id,
          receiver: receiver,
          groupID: '',
          priority: MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT,
          onlineUserOnly: false,
          isExcludedFromUnreadCount: false,
          isExcludedFromLastMessage: false,
          needReadReceipt: false,
          offlinePushInfo: OfflinePushInfo(),
          cloudCustomData: '',
          localCustomData: '',
        );
    if (res.code != 0) return null;
    return res.data;
  }

  /// 同步最后一条消息到后端，并刷新列表
  static Future<void> syncLastMessage({
    required String imUserId,
    required V2TimMessage message,
  }) async {
    final preview = messagePreview(message);
    if (preview.isEmpty) return;
    final response = await Api().post(
      '/api/friends/$imUserId/last-message',
      data: {
        'content': preview,
        'time': DateTime.now().millisecondsSinceEpoch,
      },
    );
    if (response.statusCode == 200) {
      await fetchFriendList();
      await fetchChatList();
    }
  }

  static void initGlobalMsgListener() {
    if (_msgListener != null) return;

    _msgListener = V2TimAdvancedMsgListener(
      onRecvNewMessage: (V2TimMessage message) {
        onNewMessage?.call(message);

        final imUserId = message.userID ?? message.sender ?? '';
        if (imUserId.isEmpty || imUserId == UserPro.userId) return;
        syncLastMessage(imUserId: imUserId, message: message);
      },
    );

    TencentImSDKPlugin.v2TIMManager.getMessageManager().addAdvancedMsgListener(
      listener: _msgListener!,
    );
  }

  static void removeGlobalMsgListener() {
    if (_msgListener == null) return;
    TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .removeAdvancedMsgListener(listener: _msgListener!);
    _msgListener = null;
    onNewMessage = null;
  }
}
