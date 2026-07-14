import 'package:chat_demo/import.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_tips_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info.dart';
import 'package:video_compress/video_compress.dart';

class ChatUtil {
  static final chatListNotifier = ValueNotifier<List<ChatModel>>([]);
  static final friendListNotifier = ValueNotifier<List<FriendModel>>([]);
  static final friendRequestListNotifier =
      ValueNotifier<List<FriendRequestModel>>([]);
  static final friendRequestUnreadNotifier = ValueNotifier<int>(0);
  static final notificationListNotifier =
      ValueNotifier<List<NotificationModel>>([]);
  static final notificationUnreadNotifier = ValueNotifier<int>(0);
  /// 通讯录 Tab 总未读：好友申请 + 通知
  static final addressUnreadNotifier = ValueNotifier<int>(0);
  static final unreadCountNotifier = ValueNotifier<int>(0);
  static final conversationUnreadNotifier = ValueNotifier<Map<String, int>>({});

  static V2TimAdvancedMsgListener? _msgListener;
  static V2TimConversationListener? _conversationListener;
  static void Function(V2TimMessage message)? onNewMessage;
  /// 被删好友 / 群解散时，通知当前聊天页退出
  static void Function(String type, Map<String, dynamic> data)?
      onSessionInvalidated;

  static void _refreshAddressUnread() {
    addressUnreadNotifier.value = friendRequestUnreadNotifier.value +
        notificationUnreadNotifier.value;
  }

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
    await fetchConversationUnread(list);
    return list;
  }

  static String? conversationIdFor(ChatModel chat) {
    if (chat.isAi) return null;
    if (chat.isGroup) {
      final id = chat.imGroupId ?? chat.groupId;
      if (id == null || id.isEmpty) return null;
      return 'group_$id';
    }
    final id = chat.imUserId ?? chat.id;
    if (id.isEmpty) return null;
    return 'c2c_$id';
  }

  static int unreadForChat(ChatModel chat) {
    final convId = conversationIdFor(chat);
    if (convId == null) return 0;
    return conversationUnreadNotifier.value[convId] ?? 0;
  }

  static void _updateUnreadMapFromConversations(
    List<V2TimConversation> conversations,
  ) {
    final map = Map<String, int>.from(conversationUnreadNotifier.value);
    for (final conv in conversations) {
      final id = conv.conversationID;
      if (id.isNotEmpty) {
        map[id] = conv.unreadCount ?? 0;
      }
    }
    conversationUnreadNotifier.value = map;
  }

  static Future<void> fetchConversationUnread(List<ChatModel> chats) async {
    final ids = chats
        .map(conversationIdFor)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    if (ids.isEmpty) return;

    final res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getConversationListByConversationIds(conversationIDList: ids);
    if (res.code == 0 && res.data != null) {
      _updateUnreadMapFromConversations(res.data!);
    }
  }

  static Future<void> markConversationRead({
    String? receiver,
    String? imGroupId,
  }) async {
    String? conversationID;
    if (imGroupId != null && imGroupId.isNotEmpty) {
      conversationID = 'group_$imGroupId';
    } else if (receiver != null && receiver.isNotEmpty) {
      conversationID = 'c2c_$receiver';
    }
    if (conversationID == null) return;

    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .cleanConversationUnreadMessageCount(
          conversationID: conversationID,
          cleanTimestamp: 0,
          cleanSequence: 0,
        );
  }

  /// 删除 IM 会话（未读会一并从总未读中扣除）
  static Future<void> deleteImConversation(String conversationID) async {
    if (conversationID.isEmpty) return;
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .deleteConversation(conversationID: conversationID);
    final map = Map<String, int>.from(conversationUnreadNotifier.value);
    map.remove(conversationID);
    conversationUnreadNotifier.value = map;
    await fetchTotalUnreadCount();
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

  /// 拉取好友申请列表，并更新未读数
  static Future<void> fetchFriendRequests() async {
    final data = await Api().get('/api/friends/requests');
    if (data.statusCode != 200 || data.data is! Map) return;
    final body = data.data as Map<String, dynamic>;
    if (body['data'] is! Map) return;
    final model = FriendRequestListModel.fromJson(
      body['data'] as Map<String, dynamic>,
    );
    friendRequestListNotifier.value = model.list;
    friendRequestUnreadNotifier.value = model.unreadCount;
    _refreshAddressUnread();
  }

  /// 标记好友申请已读
  static Future<void> markFriendRequestsRead() async {
    final res = await Api().post('/api/friends/requests/read');
    if (res.statusCode == 200) {
      friendRequestUnreadNotifier.value = 0;
      _refreshAddressUnread();
    }
  }

  /// 拉取通知列表，并更新未读数
  static Future<void> fetchNotifications() async {
    final data = await Api().get('/api/notifications');
    if (data.statusCode != 200 || data.data is! Map) return;
    final body = data.data as Map<String, dynamic>;
    if (body['data'] is! Map) return;
    final model = NotificationListModel.fromJson(
      body['data'] as Map<String, dynamic>,
    );
    notificationListNotifier.value = model.list;
    notificationUnreadNotifier.value = model.unreadCount;
    _refreshAddressUnread();
  }

  /// 标记通知已读
  static Future<void> markNotificationsRead() async {
    final res = await Api().post('/api/notifications/read');
    if (res.statusCode == 200) {
      notificationUnreadNotifier.value = 0;
      _refreshAddressUnread();
    }
  }

  static String messagePreview(V2TimMessage message) {
    if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
      return groupTipsPreview(message);
    }
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

  static String _groupMemberName(V2TimGroupMemberInfo? member) {
    if (member == null) return '';
    final remark = member.friendRemark;
    if (remark != null && remark.isNotEmpty) return remark;
    final nameCard = member.nameCard;
    if (nameCard != null && nameCard.isNotEmpty) return nameCard;
    final nick = member.nickName;
    if (nick != null && nick.isNotEmpty) return nick;
    return member.userID ?? '';
  }

  static String _groupMemberNames(List<V2TimGroupMemberInfo?>? members) {
    if (members == null || members.isEmpty) return '';
    return members
        .map(_groupMemberName)
        .where((name) => name.isNotEmpty)
        .join('、');
  }

  static String groupTipsPreview(V2TimMessage message) {
    final tips = message.groupTipsElem;
    if (tips == null) return '群聊通知';

    final op = _groupMemberName(tips.opMember);
    final members = _groupMemberNames(tips.memberList);

    switch (tips.type) {
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE:
        if (op.isNotEmpty && members.isNotEmpty) {
          return '$op 邀请 $members 加入了群聊';
        }
        if (members.isNotEmpty) return '$members 加入了群聊';
        return '有新成员加入群聊';
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN:
        if (members.isNotEmpty) return '$members 加入了群聊';
        if (op.isNotEmpty) return '$op 加入了群聊';
        return '有新成员加入群聊';
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT:
        if (members.isNotEmpty) return '$members 退出了群聊';
        if (op.isNotEmpty) return '$op 退出了群聊';
        return '有成员退出群聊';
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_KICKED:
        if (op.isNotEmpty && members.isNotEmpty) {
          return '$op 将 $members 移出了群聊';
        }
        return '有成员被移出群聊';
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN:
        if (op.isNotEmpty && members.isNotEmpty) {
          return '$op 将 $members 设为管理员';
        }
        return '群管理员已变更';
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN:
        if (op.isNotEmpty && members.isNotEmpty) {
          return '$op 取消了 $members 的管理员';
        }
        return '群管理员已变更';
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE:
        return '群资料已更新';
      default:
        return '群聊通知';
    }
  }

  static Future<void> _handleGroupTips(V2TimMessage message) async {
    final groupId = message.groupID ?? '';
    if (groupId.isEmpty) return;

    await syncGroupLastMessage(imGroupId: groupId, message: message);

    final type = message.groupTipsElem?.type;
    if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE ||
        type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN) {
      await fetchChatList();
    }
  }

  /// 拉取历史消息（单聊传 userID，群聊传 groupID）
  static Future<List<V2TimMessage>> fetchHistory({
    String? userID,
    String? groupID,
    int count = 20,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getHistoryMessageList(
          getType: HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
          userID: userID ?? '',
          groupID: groupID ?? '',
          count: count,
          lastMsgID: null,
          lastMsgSeq: -1,
          messageTypeList: [],
        );
    if (res.code != 0) return [];
    return res.data?.reversed.toList() ?? [];
  }

  /// 发送消息（单聊传 receiver，群聊传 groupID）
  static Future<V2TimMessage?> sendMessage({
    required String id,
    String? receiver,
    String? groupID,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessage(
          id: id,
          receiver: receiver ?? '',
          groupID: groupID ?? '',
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

  static Future<V2TimMessage?> sendText(
    String text, {
    String? receiver,
    String? groupID,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createTextMessage(text: trimmed);
    if (created.code != 0 || created.data?.id == null) return null;
    return sendMessage(
      id: created.data!.id!,
      receiver: receiver,
      groupID: groupID,
    );
  }

  static Future<V2TimMessage?> sendImage(
    String path, {
    String? receiver,
    String? groupID,
  }) async {
    final source = File(path);
    final compressed = await FlutterImageCompress.compressAndGetFile(
      source.path,
      '${source.parent.path}/chat_${DateTime.now().millisecondsSinceEpoch}.jpeg',
      quality: 80,
    );
    final imagePath = compressed?.path ?? path;
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createImageMessage(imagePath: imagePath);
    if (created.code != 0 || created.data?.id == null) return null;
    return sendMessage(
      id: created.data!.id!,
      receiver: receiver,
      groupID: groupID,
    );
  }

  static Future<V2TimMessage?> sendVideo(
    String path, {
    String? receiver,
    String? groupID,
  }) async {
    final source = File(path);
    final compressed = await VideoCompress.compressVideo(
      source.path,
      quality: VideoQuality.MediumQuality,
    );
    final videoPath = compressed?.path ?? path;
    final coverPath = await VideoCompress.getFileThumbnail(source.path);
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createVideoMessage(
          videoFilePath: videoPath,
          type: 'video/mp4',
          duration: compressed?.duration?.toInt() ?? 0,
          snapshotPath: coverPath.path,
        );
    if (created.code != 0 || created.data?.id == null) return null;
    return sendMessage(
      id: created.data!.id!,
      receiver: receiver,
      groupID: groupID,
    );
  }

  static Future<V2TimMessage?> sendSound(
    String path, {
    required int duration,
    String? receiver,
    String? groupID,
  }) async {
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createSoundMessage(soundPath: path, duration: duration);
    if (created.code != 0 || created.data?.id == null) return null;
    return sendMessage(
      id: created.data!.id!,
      receiver: receiver,
      groupID: groupID,
    );
  }

  static Future<V2TimMessage?> pickFromAlbum(
    BuildContext context, {
    String? receiver,
    String? groupID,
  }) async {
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: RequestType.common,
        maxAssets: 1,
      ),
    );
    if (assets == null || assets.isEmpty) return null;
    final file = await assets.first.file;
    if (file == null) return null;
    if (assets.first.type == AssetType.video) {
      return sendVideo(file.path, receiver: receiver, groupID: groupID);
    }
    return sendImage(file.path, receiver: receiver, groupID: groupID);
  }

  static Future<V2TimMessage?> pickFromCamera({
    String? receiver,
    String? groupID,
  }) async {
    final file = await ImagePickerUtil.openCamera();
    if (file == null) return null;
    return sendImage(file.path, receiver: receiver, groupID: groupID);
  }

  /// 清空单聊聊天记录
  static Future<bool> clearFriendMessages(String imUserId) async {
    if (imUserId.isEmpty) return false;
    final response = await Api().post('/api/friends/$imUserId/clear-messages');
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;
    await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .clearC2CHistoryMessage(userID: imUserId);
    await fetchChatList();
    return true;
  }

  /// 清空群聊聊天记录
  static Future<bool> clearGroupMessages({
    required String groupId,
    required String imGroupId,
    bool selfOnly = true,
  }) async {
    if (groupId.isEmpty) return false;
    final response = await Api().post(
      '/api/groups/$groupId/clear-messages',
      data: {'selfOnly': selfOnly},
    );
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;
    if (imGroupId.isNotEmpty) {
      await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .clearGroupHistoryMessage(groupID: imGroupId);
    }
    await fetchChatList();
    return true;
  }

  /// 退出群聊（非群主）
  static Future<bool> quitGroup({
    required String groupId,
    required String imUserId,
  }) async {
    if (groupId.isEmpty || imUserId.isEmpty) return false;
    final response =
        await Api().delete('/api/groups/$groupId/members/$imUserId');
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;
    await fetchChatList();
    return true;
  }

  /// 解散群聊（仅群主）
  static Future<bool> dissolveGroup(String groupId) async {
    if (groupId.isEmpty) return false;
    final response = await Api().delete('/api/groups/$groupId');
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;
    await fetchChatList();
    return true;
  }

  /// 删除好友
  static Future<bool> deleteFriend(String imUserId) async {
    if (imUserId.isEmpty) return false;
    final response = await Api().delete('/api/friends/$imUserId');
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;
    await fetchFriendList();
    await fetchChatList();
    return true;
  }

  /// 获取群列表
  static Future<List<GroupListItemModel>> fetchGroupList() async {
    final response = await Api().get('/api/groups');
    if (response.statusCode != 200 || response.data is! Map) return [];
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] is! Map) return [];
    return GroupListModel.fromJson(body['data'] as Map<String, dynamic>).list;
  }

  /// 获取群详情
  static Future<GroupDetailModel?> fetchGroupDetail(String groupId) async {
    if (groupId.isEmpty) return null;
    final response = await Api().get('/api/groups/$groupId');
    if (response.statusCode != 200 || response.data is! Map) return null;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] is! Map) return null;
    return GroupDetailModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// 修改群聊名称
  static Future<String?> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    if (groupId.isEmpty || name.isEmpty) return null;
    final response = await Api().patch(
      '/api/groups/$groupId',
      data: {'name': name},
    );
    if (response.statusCode != 200 || response.data is! Map) return null;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] is! Map) return null;
    await fetchChatList();
    return (body['data'] as Map<String, dynamic>)['name']?.toString();
  }

  static String groupBaseName(String name) {
    return name.replaceAll(RegExp(r'\(\d+\)$'), '').trim();
  }

  static String groupTitleWithCount(String name, int memberCount) {
    final base = groupBaseName(name);
    if (memberCount > 0) return '$base($memberCount)';
    return base;
  }

  /// 邀请群成员
  static Future<bool> inviteGroupMembers({
    required String groupId,
    required List<String> memberImUserIds,
  }) async {
    if (groupId.isEmpty || memberImUserIds.isEmpty) return false;
    final response = await Api().post(
      '/api/groups/$groupId/members',
      data: {'memberImUserIds': memberImUserIds},
    );
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    return body['code'] == 200;
  }

  /// 创建群聊
  static Future<CreateGroupResult?> createGroup({
    required List<String> memberImUserIds,
  }) async {
    final response = await Api().post(
      '/api/groups',
      data: {'memberImUserIds': memberImUserIds},
    );
    if (response.statusCode != 200 || response.data is! Map) return null;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] is! Map) return null;
    return CreateGroupResult.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// 同步群聊最后一条消息到后端，并刷新会话列表
  static Future<void> syncGroupLastMessage({
    required String imGroupId,
    required V2TimMessage message,
  }) async {
    final preview = messagePreview(message);
    if (preview.isEmpty || imGroupId.isEmpty) return;
    final response = await Api().post(
      '/api/groups/$imGroupId/last-message',
      data: {'content': preview, 'time': DateTime.now().millisecondsSinceEpoch},
    );
    if (response.statusCode == 200) {
      await fetchChatList();
    }
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
      data: {'content': preview, 'time': DateTime.now().millisecondsSinceEpoch},
    );
    if (response.statusCode == 200) {
      await fetchFriendList();
      await fetchChatList();
    }
  }

  static Map<String, dynamic> _asStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  /// 自定义消息：不当聊天消息展示
  static void _handleCustomMessage(V2TimMessage message) {
    try {
      final raw = message.customElem?.data ?? '{}';
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final data = Map<String, dynamic>.from(decoded);
      final meta = _asStringKeyMap(data['meta']);
      final payload = {...data, ...meta};
      if (message.sender != null && message.sender!.isNotEmpty) {
        payload.putIfAbsent('fromImUserId', () => message.sender);
      }

      switch (data['type']) {
        case 'friend_request':
          fetchFriendRequests();
          break;
        case 'friend_deleted':
          final userId =
              '${payload['fromImUserId'] ?? payload['imUserId'] ?? ''}';
          if (userId.isNotEmpty) {
            deleteImConversation('c2c_$userId');
          }
          fetchChatList();
          fetchFriendList();
          fetchNotifications();
          onSessionInvalidated?.call('friend_deleted', payload);
          break;
        case 'group_dissolved':
          final groupId =
              '${payload['imGroupId'] ?? payload['groupId'] ?? ''}';
          if (groupId.isNotEmpty) {
            deleteImConversation('group_$groupId');
          }
          fetchChatList();
          fetchNotifications();
          onSessionInvalidated?.call('group_dissolved', payload);
          break;
      }
    } catch (_) {}
  }

  static void initGlobalMsgListener() {
    if (_msgListener != null) return;

    _msgListener = V2TimAdvancedMsgListener(
      onRecvNewMessage: (V2TimMessage message) {
        if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM) {
          _handleCustomMessage(message);
          return;
        }

        onNewMessage?.call(message);

        final groupId = message.groupID ?? '';
        if (groupId.isNotEmpty) {
          if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            _handleGroupTips(message);
          } else {
            syncGroupLastMessage(imGroupId: groupId, message: message);
          }
          return;
        }

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
    onSessionInvalidated = null;
  }

  static Future<void> fetchTotalUnreadCount() async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getTotalUnreadMessageCount();
    if (res.code == 0) {
      unreadCountNotifier.value = res.data ?? 0;
    }
  }

  static void initUnreadListener() {
    if (_conversationListener != null) return;

    _conversationListener = V2TimConversationListener(
      onTotalUnreadMessageCountChanged: (totalUnreadCount) {
        unreadCountNotifier.value = totalUnreadCount;
      },
      onConversationChanged: _updateUnreadMapFromConversations,
      onNewConversation: _updateUnreadMapFromConversations,
    );

    TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .addConversationListener(listener: _conversationListener!);
    fetchTotalUnreadCount();
  }

  static void removeUnreadListener() {
    if (_conversationListener == null) return;
    TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .removeConversationListener(listener: _conversationListener!);
    _conversationListener = null;
    unreadCountNotifier.value = 0;
    conversationUnreadNotifier.value = {};
  }

  static Future<void> deleteMessage() async {
    
  }
}
