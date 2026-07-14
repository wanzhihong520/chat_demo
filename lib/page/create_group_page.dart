import 'package:azlistview/azlistview.dart';
import 'package:chat_demo/import.dart';

class CreateGroupPage extends StatefulWidget {
  final String? inviteGroupId;
  final Set<String> excludeImUserIds;

  const CreateGroupPage({
    super.key,
    this.inviteGroupId,
    this.excludeImUserIds = const {},
  });

  bool get isInvite => inviteGroupId != null && inviteGroupId!.isNotEmpty;

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  List<FriendModel> _friendList = [];
  final Set<String> _selectedIds = {};
  bool _submitting = false;

  bool get _hasSelected => _selectedIds.isNotEmpty;
  bool get _isInvite => widget.isInvite;

  @override
  void initState() {
    super.initState();
    _prepareFriendList();
    ChatUtil.friendListNotifier.addListener(_onFriendListChanged);
  }

  @override
  void dispose() {
    ChatUtil.friendListNotifier.removeListener(_onFriendListChanged);
    super.dispose();
  }

  void _onFriendListChanged() {
    _prepareFriendList();
    if (mounted) setState(() {});
  }

  void _prepareFriendList() {
    _friendList = UserPro.friendList
        .where((f) => !widget.excludeImUserIds.contains(f.imUserId))
        .map((f) {
      final tag = f.tag.isNotEmpty ? f.tag : FriendModel.tagFromName(f.name);
      if (tag == f.tag) return f;
      return FriendModel(
        imUserId: f.imUserId,
        name: f.name,
        avatarUrl: f.avatarUrl,
        isAi: f.isAi,
        tag: tag,
      );
    }).toList();
    SuspensionUtil.sortListBySuspensionTag(_friendList);
    SuspensionUtil.setShowSuspensionStatus(_friendList);
  }

  void _toggleSelect(FriendModel friend) {
    setState(() {
      if (_selectedIds.contains(friend.imUserId)) {
        _selectedIds.remove(friend.imUserId);
      } else {
        _selectedIds.add(friend.imUserId);
      }
    });
  }

  Future<void> _onDone() async {
    if (!_hasSelected || _submitting) return;
    setState(() => _submitting = true);

    if (_isInvite) {
      final ok = await ChatUtil.inviteGroupMembers(
        groupId: widget.inviteGroupId!,
        memberImUserIds: _selectedIds.toList(),
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (ok) {
        showToast('邀请成功');
        backPage(context, true);
      } else {
        showToast('邀请失败');
      }
      return;
    }

    final group = await ChatUtil.createGroup(
      memberImUserIds: _selectedIds.toList(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (group == null || group.imGroupId.isEmpty) {
      showToast('创建群聊失败');
      return;
    }
    await ChatUtil.fetchChatList();
    if (!mounted) return;
    jumpReplacementPage(
      context,
      ChatDetailPage(
        groupId: group.groupId,
        imGroupId: group.imGroupId,
        title: group.name,
        avatarUrl: group.avatarUrl,
      ),
    );
  }

  Widget _buildCheckbox(bool selected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.green : Colors.transparent,
        border: Border.all(
          color: selected ? Colors.green : Colors.grey,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }

  Widget _buildItem(FriendModel item) {
    final selected = _selectedIds.contains(item.imUserId);
    final url = item.avatarUrl;
    final fullUrl = url.isEmpty
        ? ''
        : (url.startsWith('http') ? url : BASE_URL + url);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleSelect(item),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _buildCheckbox(selected),
                SizedBox(width: 12),
                PortraitUtil(url: fullUrl, width: 48, height: 48),
                SizedBox(width: 12),
                Expanded(
                  child: Text(item.name, style: FontStyleUtils.blackTitle),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _hasSelected && !_submitting;
    final actionText = _submitting
        ? (_isInvite ? '邀请中' : '创建中')
        : '完成';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isInvite ? '选择联系人' : '发起群聊',
          style: FontStyleUtils.blackTitle,
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: canSubmit ? _onDone : null,
                child: ContainerUtils(
                  radius: 4,
                  height: 32,
                  padding: [12, 12, 0, 0],
                  color: canSubmit ? Colors.green : Colors.grey,
                  child: Text(actionText, style: FontStyleUtils.whiteBody),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _friendList.isEmpty
          ? Center(child: Text('暂无好友', style: FontStyleUtils.grayBody))
          : AzListView(
              data: _friendList,
              itemCount: _friendList.length,
              indexBarData: kIndexBarData,
              susItemHeight: 32,
              susItemBuilder: (context, index) {
                return Container(
                  height: 32,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 16),
                  color: Color.fromRGBO(230, 230, 230, 1),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _friendList[index].getSuspensionTag(),
                    style: FontStyleUtils.blackBody,
                  ),
                );
              },
              itemBuilder: (context, index) => _buildItem(_friendList[index]),
            ),
    );
  }
}
