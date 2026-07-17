import 'package:chat_demo/import.dart';

class ChatInfoPage extends StatefulWidget {
  final bool isGroup;
  final String name;
  final String avatarUrl;
  final String? receiver;
  final String? groupId;
  final String? imGroupId;

  const ChatInfoPage({
    super.key,
    required this.isGroup,
    required this.name,
    this.avatarUrl = '',
    this.receiver,
    this.groupId,
    this.imGroupId,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  GroupDetailModel? _groupDetail;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isGroup) _loadGroupDetail();
  }

  Future<void> _loadGroupDetail() async {
    final id = widget.imGroupId ?? widget.groupId ?? '';
    if (id.isEmpty) return;
    setState(() => _loading = true);
    final detail = await ChatUtil.fetchGroupDetail(id);
    if (!mounted) return;
    setState(() {
      _groupDetail = detail;
      _loading = false;
    });
  }

  String _fullAvatarUrl(String url) {
    if (url.isEmpty) return '';
    return url.startsWith('http') ? url : BASE_URL + url;
  }

  bool get _isOwner =>
      _groupDetail != null && _groupDetail!.ownerImUserId == UserPro.userId;

  String get _groupDangerText => _isOwner ? '解散群聊' : '退出群聊';

  Future<void> _clearMessages(BuildContext context) async {
    if (widget.isGroup) {
      final gid = widget.imGroupId ?? widget.groupId ?? '';
      if (gid.isEmpty) return;

      final confirmed = await ConfirmDialogUtil.show(
        context,
        message: '确定清空聊天记录吗？',
      );
      if (!confirmed || !context.mounted) return;

      final ok = await ChatUtil.clearGroupMessages(
        groupId: gid,
        imGroupId: gid,
      );
      if (!context.mounted) return;
      if (ok) {
        showToast('已清空');
        backPage(context, true);
      } else {
        showToast('清空失败');
      }
      return;
    }
    final imUserId = widget.receiver ?? '';
    if (imUserId.isEmpty) return;

    final confirmed = await ConfirmDialogUtil.show(
      context,
      message: '确定清空聊天记录吗？',
    );
    if (!confirmed || !context.mounted) return;

    final ok = await ChatUtil.clearFriendMessages(imUserId);
    if (!context.mounted) return;
    if (ok) {
      showToast('已清空');
      backPage(context, true);
    } else {
      showToast('清空失败');
    }
  }

  Future<void> _leaveGroup(BuildContext context) async {
    final groupId = widget.imGroupId ?? widget.groupId ?? '';
    if (groupId.isEmpty) return;
    if (_groupDetail == null) {
      showToast('加载中，请稍候');
      return;
    }

    if (_isOwner) {
      final confirmed = await ConfirmDialogUtil.show(
        context,
        message: '确定解散该群聊吗？',
        confirmText: '解散',
      );
      if (!confirmed || !context.mounted) return;

      final ok = await ChatUtil.dissolveGroup(
        groupId: widget.imGroupId ?? groupId,
      );
      if (!context.mounted) return;
      if (ok) {
        showToast('已解散');
        ChatUtil.onSessionInvalidated = null;
        backPage(context, 'deleted');
      } else {
        showToast('解散失败');
      }
      return;
    }

    final imUserId = UserPro.userId;
    if (imUserId.isEmpty) return;

    final confirmed = await ConfirmDialogUtil.show(
      context,
      message: '确定退出该群聊吗？',
      confirmText: '退出',
    );
    if (!confirmed || !context.mounted) return;

    final ok = await ChatUtil.quitGroup(
      groupId: widget.imGroupId ?? groupId,
      imUserId: imUserId,
    );
    if (!context.mounted) return;
    if (ok) {
      showToast('已退出');
      ChatUtil.onSessionInvalidated = null;
      backPage(context, 'deleted');
    } else {
      showToast('退出失败');
    }
  }

  Future<void> _deleteFriend(BuildContext context) async {
    if (widget.isGroup) {
      await _leaveGroup(context);
      return;
    }
    final imUserId = widget.receiver ?? '';
    if (imUserId.isEmpty) return;

    final confirmed = await ConfirmDialogUtil.show(
      context,
      message: '确定删除好友吗？',
      confirmText: '删除',
    );
    if (!confirmed || !context.mounted) return;

    final ok = await ChatUtil.deleteFriend(imUserId);
    if (!context.mounted) return;
    if (ok) {
      showToast('已删除');
      ChatUtil.onSessionInvalidated = null;
      backPage(context, 'deleted');
    } else {
      showToast('删除失败');
    }
  }

  Widget _buildFriendHeader() {
    final url = _fullAvatarUrl(widget.avatarUrl);
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortraitUtil(url: url, width: 64, height: 64, radius: 4),
          SizedBox(width: 12),
          Expanded(
            child: Text(widget.name, style: FontStyleUtils.blackBoldTitle),
          ),
        ],
      ),
    );
  }

  bool _isFriend(String imUserId) {
    return UserPro.friendList.any((f) => f.imUserId == imUserId);
  }

  void _openMemberProfile(GroupMemberModel member) {
    if (member.imUserId == UserPro.userId) return;
    jumpPage(
      context,
      FriendInfoPage(
        searchModel: SearchModel(
          id: member.userId,
          username: member.username,
          nickname: member.displayName,
          avatarUrl: _fullAvatarUrl(member.avatarUrl),
          imUserId: member.imUserId,
          isFriend: _isFriend(member.imUserId),
        ),
      ),
    );
  }

  Future<void> _openInviteMembers() async {
    final groupId = widget.imGroupId ?? widget.groupId ?? '';
    if (groupId.isEmpty) return;

    final excludeIds =
        _groupDetail?.members.map((m) => m.imUserId).toSet() ?? {};
    final invited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupPage(
          inviteGroupId: groupId,
          inviteImGroupId: groupId,
          excludeImUserIds: excludeIds,
        ),
      ),
    );
    if (invited == true && mounted) await _loadGroupDetail();
  }

  Widget _buildMemberItem(GroupMemberModel member) {
    return GestureDetector(
      onTap: () => _openMemberProfile(member),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PortraitUtil(
            url: _fullAvatarUrl(member.avatarUrl),
            width: 52,
            height: 52,
            radius: 4,
          ),
          SizedBox(height: 6),
          Text(
            member.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: FontStyleUtils.graySmallBody,
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberButton() {
    return GestureDetector(
      onTap: _openInviteMembers,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            child: Icon(Icons.add, color: Colors.grey[600], size: 28),
          ),
          SizedBox(height: 6),
          Text(
            '邀请',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: FontStyleUtils.graySmallBody,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupMemberGrid() {
    if (_loading) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final members = _groupDetail?.members ?? [];
    final itemCount = members.length + 1;

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 4,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          if (index == members.length) {
            return _buildAddMemberButton();
          }
          return _buildMemberItem(members[index]);
        },
      ),
    );
  }

  String get _groupDisplayName =>
      ChatUtil.groupBaseName(_groupDetail?.name ?? widget.name);

  Future<void> _openEditGroupName() async {
    final groupId = widget.groupId ?? '';
    if (groupId.isEmpty) return;

    final newName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditGroupNamePage(groupId: groupId, name: _groupDisplayName),
      ),
    );
    if (newName != null && mounted) {
      await _loadGroupDetail();
    }
  }

  Widget _buildGroupNameRow() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('群聊名称', style: FontStyleUtils.blackTitle),
          Row(
            children: [
              Text(
                _groupDisplayName,
                style: FontStyleUtils.grayBody,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
            ],
          ),
        ],
      ),
    ).withOnTap(_openEditGroupName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('聊天信息', style: FontStyleUtils.blackTitle),
        shape: Border(),
      ),
      body: ListView(
        children: [
          widget.isGroup ? _buildGroupMemberGrid() : _buildFriendHeader(),
          if (widget.isGroup) ...[SizedBox(height: 12), _buildGroupNameRow()],
          SizedBox(height: 12),
          _arrowRow(text: '清空聊天记录', onTap: () => _clearMessages(context)),
          SizedBox(height: 12),
          _dangerRow(
            text: widget.isGroup ? _groupDangerText : '删除好友',
            onTap: () => _deleteFriend(context),
          ),
        ],
      ),
    );
  }

  Widget _arrowRow({required String text, required VoidCallback onTap}) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(text, style: FontStyleUtils.blackTitle),
          Spacer(),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
        ],
      ),
    ).withOnTap(onTap);
  }

  Widget _dangerRow({required String text, required VoidCallback onTap}) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.red, fontSize: 16)),
      ),
    ).withOnTap(onTap);
  }
}
