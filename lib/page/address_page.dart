import 'package:azlistview/azlistview.dart';
import 'package:chat_demo/import.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  static const String _newFriendName = '新的朋友';
  static const String _groupChatName = '群聊';
  static const String _notificationName = '通知中心';
  static const String _topTag = '↑';

  List<FriendModel> _prepareFriendList(List<FriendModel> source) {
    final list = source.map((f) {
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
    SuspensionUtil.sortListBySuspensionTag(list);
    SuspensionUtil.setShowSuspensionStatus(list);
    list.insertAll(0, [
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
      FriendModel(
        imUserId: '',
        name: _notificationName,
        avatarUrl: '',
        isAi: false,
        tag: _topTag,
      ),
    ]);
    return list;
  }

  Widget _buildItem(BuildContext context, FriendModel item, ContactProvider contact) {
    if (item.name == _newFriendName) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChatItemUtil(
            onTap: () => jumpPage(context, NewFriendPage()),
            name: _newFriendName,
            asset: 'assets/images/add_friend.svg',
            boxColor: Colors.orange,
            unreadCount: contact.friendRequestUnread,
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
    if (item.name == _notificationName) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChatItemUtil(
            name: _notificationName,
            asset: 'assets/images/chat_history.svg',
            boxColor: Colors.blue,
            unreadCount: contact.notificationUnread,
            onTap: () => jumpPage(context, NotificationCenterPage()),
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
      body: Consumer<ContactProvider>(
        builder: (context, contact, _) {
          final friendList = _prepareFriendList(contact.friendList);
          return AzListView(
            data: friendList,
            itemCount: friendList.length,
            indexBarData: [_topTag, ...kIndexBarData],
            susItemHeight: 32,
            susItemBuilder: (context, index) {
              if (friendList[index].getSuspensionTag() == _topTag) {
                return Container();
              }
              return Container(
                height: 32,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 16),
                color: Color.fromRGBO(230, 230, 230, 1),
                alignment: Alignment.centerLeft,
                child: Text(
                  friendList[index].getSuspensionTag(),
                  style: FontStyleUtils.blackBody,
                ),
              );
            },
            itemBuilder: (context, index) =>
                _buildItem(context, friendList[index], contact),
          );
        },
      ),
    );
  }
}
