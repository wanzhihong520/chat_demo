import 'package:azlistview/azlistview.dart';
import 'package:chat_demo/import.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  static const String _newFriendName = '新的朋友';
  static const String _groupChatName = '群聊';
  static const String _topTag = '↑';

  List<FriendModel> _friendList = [];

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
    _friendList = UserPro.friendList.map((f) {
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
    _friendList.insertAll(0, [
      FriendModel(
        imUserId: '',
        name: _newFriendName,
        avatarUrl: '',
        isAi: false,
        tag: _topTag,
      ),
      FriendModel(
        imUserId: '',
        name: _groupChatName,
        avatarUrl: '',
        isAi: false,
        tag: _topTag,
      ),
    ]);
  }

  Widget _buildItem(FriendModel item) {
    if (item.name == _newFriendName) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: ChatUtil.friendRequestUnreadNotifier,
            builder: (_, unread, __) {
              return ChatItemUtil(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewFriendPage()),
                  );
                  if (mounted) {
                    _prepareFriendList();
                    setState(() {});
                  }
                },
                name: _newFriendName,
                asset: 'assets/images/add_friend.svg',
                boxColor: Colors.orange,
                unreadCount: unread,
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[200]),
        ],
      );
    }
    if (item.name == _groupChatName) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChatItemUtil(
            name: _groupChatName,
            asset: 'assets/images/group.svg',
            boxColor: Colors.green,
            onTap: () => jumpPage(context, GroupListPage()),
          ),
          Divider(height: 1, color: Colors.grey[200]),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChatItemUtil(
          name: item.name,
          avatarUrl: item.avatarUrl,
          onTap: () {
            final url = item.avatarUrl;
            final fullUrl = url.isEmpty
                ? ''
                : (url.startsWith('http') ? url : BASE_URL + url);
            jumpPage(
              context,
              FriendInfoPage(
                searchModel: SearchModel(
                  id: item.imUserId,
                  username: item.imUserId,
                  nickname: item.name,
                  avatarUrl: fullUrl,
                  imUserId: item.imUserId,
                  isFriend: true,
                ),
              ),
            );
          },
        ),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('通讯录', style: FontStyleUtils.blackTitle),
        actions: [
          PopupmenuUtil(
            icon: SvgPicture.asset(
              'assets/images/add.svg',
              width: 28,
              height: 28,
            ),
            items: [
              PopupMenuItemModel(
                icon: 'assets/images/chat.svg',
                text: '发起群聊',
                onTap: () => jumpPage(context, CreateGroupPage()),
              ),
              PopupMenuItemModel(
                icon: 'assets/images/add_friend.svg',
                text: '添加好友',
                onTap: () => jumpPage(context, SearchPage()),
              ),
              PopupMenuItemModel(
                icon: 'assets/images/scan.svg',
                text: '扫一扫',
                onTap: () => showToast('当前功能暂未开放'),
              ),
              PopupMenuItemModel(
                icon: 'assets/images/qr_code.svg',
                text: '收款码',
                onTap: () => showToast('当前功能暂未开放'),
              ),
            ],
          ),
        ],
      ),
      body: AzListView(
        data: _friendList,
        itemCount: _friendList.length,
        indexBarData: [_topTag, ...kIndexBarData],
        susItemHeight: 32,
        susItemBuilder: (context, index) {
          if (_friendList[index].getSuspensionTag() == _topTag) {
            return Container();
          }
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
