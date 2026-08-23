import 'package:chat_demo/import.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimGroupListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_add_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_filter_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_role_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_tips_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info.dart';
import 'package:video_compress/video_compress.dart';

class ChatUtil {
  static V2TimAdvancedMsgListener? _msgListener;
  static V2TimConversationListener? _conversationListener;
  static V2TimGroupListener? _groupListener;
  static void Function(V2TimMessage message)? onNewMessage;

  /// 被删好友 / 群解散时，通知当前聊天页退出
  static void Function(String type, Map<String, dynamic> data)?
  onSessionInvalidated;

  /// 邀请/退群 tips 可能已写入 IM，通知当前群聊页重拉历史
  static void Function(String imGroupId)? onGroupHistoryNeedRefresh;

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
    return AppProviders.chat.unreadOf(conversationIdFor(chat));
  }

  static void _updateUnreadMapFromConversations(
    List<V2TimConversation> conversations,
  ) {
    final map = Map<String, int>.from(AppProviders.chat.conversationUnread);
    for (final conv in conversations) {
      final id = conv.conversationID;
      if (id.isNotEmpty) {
        map[id] = conv.unreadCount ?? 0;
      }
    }
    AppProviders.chat.setConversationUnread(map);
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
    AppProviders.chat.removeConversationUnread(conversationID);
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
    AppProviders.contact.setFriendRequests(model.list);
    AppProviders.contact.setFriendRequestUnread(model.unreadCount);
  }

  /// 标记好友申请已读
  static Future<void> markFriendRequestsRead() async {
    final res = await Api().post('/api/friends/requests/read');
    if (res.statusCode == 200) {
      AppProviders.contact.setFriendRequestUnread(0);
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
    AppProviders.contact.setNotifications(model.list);
    AppProviders.contact.setNotificationUnread(model.unreadCount);
  }

  /// 标记通知已读
  static Future<void> markNotificationsRead() async {
    final res = await Api().post('/api/notifications/read');
    if (res.statusCode == 200) {
      AppProviders.contact.setNotificationUnread(0);
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
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return '位置';
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
    if (tips == null) return '';

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
        // 建群带人时常见 JOIN，按邀请/入群展示
        if (members.isNotEmpty) return '$members 加入了群聊';
        if (op.isNotEmpty) return '$op 加入了群聊';
        return '有新成员加入群聊';
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT:
        if (members.isNotEmpty) return '$members 退出了群聊';
        if (op.isNotEmpty) return '$op 退出了群聊';
        return '有成员退出群聊';
      default:
        return '';
    }
  }

  /// 后端发的激活/邀请/退群文案，聊天页按 tips 灰条展示
  static bool isGroupSystemText(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    if (t == '发起了群聊' || t == '有新成员加入群聊') return true;
    if (t.contains('邀请') && t.contains('加入')) return true;
    if (t.contains('退出了群聊') || t.contains('退出群聊')) return true;
    return false;
  }

  static bool _isInviteOrQuitTips(int? type) {
    return type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE ||
        type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN ||
        type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT;
  }

  static Future<void> _handleGroupTips(V2TimMessage message) async {
    final groupId = message.groupID ?? '';
    if (groupId.isEmpty) return;

    final type = message.groupTipsElem?.type;
    if (!_isInviteOrQuitTips(type)) return;

    await syncGroupLastMessage(imGroupId: groupId, message: message);
    await fetchChatList();
  }

  /// 邀请者自己常收不到 tips 推送：主动拉历史同步会话，并通知聊天页刷新
  static Future<void> refreshGroupSessionAfterTips(String imGroupId) async {
    if (imGroupId.isEmpty) return;
    // 等 IM 落库；失败再补拉一次
    await Future.delayed(const Duration(milliseconds: 800));
    var list = await fetchHistory(groupID: imGroupId, count: 20);
    if (list.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      list = await fetchHistory(groupID: imGroupId, count: 20);
    }
    if (list.isNotEmpty) {
      await syncGroupLastMessage(imGroupId: imGroupId, message: list.last);
    } else {
      await fetchChatList();
    }
    onGroupHistoryNeedRefresh?.call(imGroupId);
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

  static Future<V2TimMessage?> sendLocation({
    required String desc,
    required double longitude,
    required double latitude,
    String? receiver,
    String? groupID,
  }) async {
    final normalizedDesc = desc.trim();
    if (normalizedDesc.isEmpty) return null;
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createLocationMessage(
          desc: normalizedDesc,
          longitude: longitude,
          latitude: latitude,
        );
    if (created.code != 0 || created.data?.id == null) {
      debugPrint(
        'createLocationMessage failed: ${created.code} ${created.desc}',
      );
      return null;
    }
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
    bool isVideo = false,
  }) async {
    final file = await ImagePickerUtil.openCamera(isVideo: isVideo);
    if (file == null) return null;
    if (isVideo) {
      return sendVideo(file.path, receiver: receiver, groupID: groupID);
    }
    return sendImage(file.path, receiver: receiver, groupID: groupID);
  }

  /// 清空单聊聊天记录
  static Future<bool> clearFriendMessages(String imUserId) async {
    if (imUserId.isEmpty) return false;
    final response = await Api().post(
      '/api/friends/${_enc(imUserId)}/clear-messages',
    );
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
      '/api/groups/${_enc(groupId)}/clear-messages',
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

  /// 群 ID：后端与 IM 相同，都是 SDK 的 groupID
  static String _groupId(String groupId, [String? imGroupId]) {
    if (imGroupId != null && imGroupId.isNotEmpty) return imGroupId;
    return groupId;
  }

  /// URL 路径参数编码（SDK groupID 常含特殊字符）
  static String _enc(String id) => Uri.encodeComponent(id);

  /// 退出群聊：SDK quitGroup → DELETE /api/groups/:groupId/members/:imUserId
  static Future<bool> quitGroup({
    required String groupId,
    String? imGroupId,
    required String imUserId,
  }) async {
    final gid = _groupId(groupId, imGroupId);
    if (gid.isEmpty || imUserId.isEmpty) return false;

    final imRes = await TencentImSDKPlugin.v2TIMManager.quitGroup(groupID: gid);
    if (imRes.code != 0) {
      debugPrint('quitGroup IM failed: ${imRes.code} ${imRes.desc}');
      return false;
    }

    final response = await Api().delete(
      '/api/groups/${_enc(gid)}/members/${_enc(imUserId)}',
    );
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;
    await deleteImConversation('group_$gid');
    await fetchChatList();
    return true;
  }

  /// 踢人：SDK kickGroupMember → DELETE /api/groups/:groupId/members/:imUserId
  static Future<bool> kickGroupMember({
    required String groupId,
    String? imGroupId,
    required String memberImUserId,
  }) async {
    final gid = _groupId(groupId, imGroupId);
    if (gid.isEmpty || memberImUserId.isEmpty) return false;

    final imRes = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .kickGroupMember(
          groupID: gid,
          memberList: [memberImUserId],
          reason: '',
        );
    if (imRes.code != 0) {
      debugPrint('kickGroupMember failed: ${imRes.code} ${imRes.desc}');
      return false;
    }

    final response = await Api().delete(
      '/api/groups/${_enc(gid)}/members/${_enc(memberImUserId)}',
    );
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    return body['code'] == 200;
  }

  /// Work 群客户端无法 dismiss：踢光其他人后自己 quit
  static Future<bool> _dissolveWorkGroupFallback(String gid) async {
    final listRes = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupMemberList(
          groupID: gid,
          filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
          nextSeq: '0',
          count: 100,
        );
    if (listRes.code != 0) {
      debugPrint('getGroupMemberList failed: ${listRes.code} ${listRes.desc}');
      return false;
    }
    final myId = UserPro.userId;
    final others = (listRes.data?.memberInfoList ?? [])
        .whereType<V2TimGroupMemberFullInfo>()
        .map((m) => m.userID)
        .whereType<String>()
        .where((id) => id.isNotEmpty && id != myId)
        .toList();
    if (others.isNotEmpty) {
      final kickRes = await TencentImSDKPlugin.v2TIMManager
          .getGroupManager()
          .kickGroupMember(groupID: gid, memberList: others, reason: '群聊已解散');
      if (kickRes.code != 0) {
        debugPrint('kickGroupMember failed: ${kickRes.code} ${kickRes.desc}');
        return false;
      }
    }
    final quitRes = await TencentImSDKPlugin.v2TIMManager.quitGroup(
      groupID: gid,
    );
    if (quitRes.code != 0) {
      debugPrint('quit after kick failed: ${quitRes.code} ${quitRes.desc}');
      return false;
    }
    return true;
  }

  /// 解散群聊：SDK dismissGroup → DELETE /api/groups/:groupId
  static Future<bool> dissolveGroup({
    required String groupId,
    String? imGroupId,
  }) async {
    final gid = _groupId(groupId, imGroupId);
    if (gid.isEmpty) return false;

    final dismissRes = await TencentImSDKPlugin.v2TIMManager.dismissGroup(
      groupID: gid,
    );
    if (dismissRes.code != 0) {
      // Work 不支持客户端解散，降级踢人+退出
      debugPrint(
        'dismissGroup failed, fallback: ${dismissRes.code} ${dismissRes.desc}',
      );
      final ok = await _dissolveWorkGroupFallback(gid);
      if (!ok) return false;
    }

    final response = await Api().delete('/api/groups/${_enc(gid)}');
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;
    await deleteImConversation('group_$gid');
    await fetchChatList();
    return true;
  }

  /// 删除好友
  static Future<bool> deleteFriend(String imUserId) async {
    if (imUserId.isEmpty) return false;
    final response = await Api().delete('/api/friends/${_enc(imUserId)}');
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
    final response = await Api().get('/api/groups/${_enc(groupId)}');
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
      '/api/groups/${_enc(groupId)}',
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

  /// 邀请：SDK inviteUserToGroup → POST members → 等后端文字/ tip，必要时前端发消息激活
  static Future<bool> inviteGroupMembers({
    required String groupId,
    String? imGroupId,
    required List<String> memberImUserIds,
  }) async {
    final gid = _groupId(groupId, imGroupId);
    if (gid.isEmpty || memberImUserIds.isEmpty) return false;

    final imRes = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .inviteUserToGroup(groupID: gid, userList: memberImUserIds);
    if (imRes.code != 0) {
      debugPrint('inviteUserToGroup failed: ${imRes.code} ${imRes.desc}');
      return false;
    }

    final response = await Api().post(
      '/api/groups/${_enc(gid)}/members',
      data: {'memberImUserIds': memberImUserIds},
    );
    if (response.statusCode != 200 || response.data is! Map) return false;
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) return false;

    await ensureWorkGroupActivated(gid, fallbackText: '有新成员加入群聊');
    return true;
  }

  /// 创建：SDK createGroup(Work)+成员 → POST /api/groups → 激活 → 进聊天页拉历史
  static Future<CreateGroupResult?> createGroup({
    required List<String> memberImUserIds,
  }) async {
    final memberList = memberImUserIds
        .map(
          (id) => V2TimGroupMember(
            userID: id,
            role: GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER,
          ),
        )
        .toList();

    // 非静默：memberList 直接拉人进群，会产生系统 tip
    final imRes = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .createGroup(
          groupType: GroupType.Work,
          groupName: '群聊',
          notification: '',
          introduction: '',
          faceUrl: '',
          isAllMuted: false,
          isSupportTopic: false,
          addOpt: GroupAddOptTypeEnum.V2TIM_GROUP_ADD_FORBID,
          memberList: memberList,
        );
    if (imRes.code != 0 || (imRes.data ?? '').isEmpty) {
      debugPrint('createGroup IM failed: ${imRes.code} ${imRes.desc}');
      return null;
    }
    final sdkGroupId = imRes.data!;

    final response = await Api().post(
      '/api/groups',
      data: {'imGroupId': sdkGroupId, 'memberImUserIds': memberImUserIds},
    );
    if (response.statusCode != 200 || response.data is! Map) {
      await TencentImSDKPlugin.v2TIMManager.quitGroup(groupID: sdkGroupId);
      return null;
    }
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200 || body['data'] is! Map) {
      await TencentImSDKPlugin.v2TIMManager.quitGroup(groupID: sdkGroupId);
      return null;
    }
    final parsed = CreateGroupResult.fromJson(
      body['data'] as Map<String, dynamic>,
    );
    final result = CreateGroupResult(
      groupId: sdkGroupId,
      imGroupId: sdkGroupId,
      name: parsed.name.isNotEmpty ? parsed.name : '群聊',
      avatarUrl: parsed.avatarUrl,
      memberCount: parsed.memberCount > 0
          ? parsed.memberCount
          : memberImUserIds.length + 1,
    );

    // 后端会发激活文字；没有 tip/文字时前端补发，再刷新
    await ensureWorkGroupActivated(sdkGroupId, fallbackText: '发起了群聊');
    return result;
  }

  /// Work 群：先等后端文字/系统 tip；都没有则当前用户发一条群文本激活会话
  static Future<void> ensureWorkGroupActivated(
    String imGroupId, {
    String fallbackText = '发起了群聊',
  }) async {
    if (imGroupId.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 600));
    var list = await fetchHistory(groupID: imGroupId, count: 20);
    if (!_historyHasTipOrText(list)) {
      await Future.delayed(const Duration(milliseconds: 400));
      list = await fetchHistory(groupID: imGroupId, count: 20);
    }
    if (!_historyHasTipOrText(list)) {
      final sent = await sendText(fallbackText, groupID: imGroupId);
      if (sent != null) {
        await syncGroupLastMessage(imGroupId: imGroupId, message: sent);
      } else {
        await fetchChatList();
      }
    } else {
      await syncGroupLastMessage(imGroupId: imGroupId, message: list.last);
    }
    // 立刻通知聊天页重拉，不再额外长等
    onGroupHistoryNeedRefresh?.call(imGroupId);
  }

  static bool _historyHasTipOrText(List<V2TimMessage> list) {
    for (final m in list) {
      if (m.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
        if (groupTipsPreview(m).isNotEmpty) return true;
        continue;
      }
      if (m.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
        final t = m.textElem?.text?.trim() ?? '';
        if (t.isNotEmpty) return true;
      }
    }
    return false;
  }

  /// 同步群聊最后一条消息到后端，并刷新会话列表
  static Future<void> syncGroupLastMessage({
    required String imGroupId,
    required V2TimMessage message,
  }) async {
    final preview = messagePreview(message);
    if (preview.isEmpty || imGroupId.isEmpty) return;
    final response = await Api().post(
      '/api/groups/${_enc(imGroupId)}/last-message',
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
      '/api/friends/${_enc(imUserId)}/last-message',
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
          final groupId = '${payload['imGroupId'] ?? payload['groupId'] ?? ''}';
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
    _initGroupListener();
  }

  /// 群成员变更回调：补拉历史，避免 tips 推送丢失
  static void _initGroupListener() {
    if (_groupListener != null) return;
    _groupListener = V2TimGroupListener(
      onMemberInvited: (groupID, opUser, memberList) {
        refreshGroupSessionAfterTips(groupID);
      },
      onMemberEnter: (groupID, memberList) {
        refreshGroupSessionAfterTips(groupID);
      },
      onMemberLeave: (groupID, member) {
        refreshGroupSessionAfterTips(groupID);
      },
    );
    TencentImSDKPlugin.v2TIMManager.addGroupListener(listener: _groupListener!);
  }

  static void removeGlobalMsgListener() {
    if (_msgListener != null) {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .removeAdvancedMsgListener(listener: _msgListener!);
      _msgListener = null;
    }
    if (_groupListener != null) {
      TencentImSDKPlugin.v2TIMManager.removeGroupListener(
        listener: _groupListener!,
      );
      _groupListener = null;
    }
    onNewMessage = null;
    onSessionInvalidated = null;
    onGroupHistoryNeedRefresh = null;
  }

  static Future<void> fetchTotalUnreadCount() async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getTotalUnreadMessageCount();
    if (res.code == 0) {
      AppProviders.chat.setUnreadCount(res.data ?? 0);
    }
  }

  static void initUnreadListener() {
    if (_conversationListener != null) return;

    _conversationListener = V2TimConversationListener(
      onTotalUnreadMessageCountChanged: (totalUnreadCount) {
        AppProviders.chat.setUnreadCount(totalUnreadCount);
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
    AppProviders.chat.setUnreadCount(0);
    AppProviders.chat.setConversationUnread({});
  }

  static Future<void> deleteMessage() async {}
}
