import 'package:chat_demo/import.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    ChatUtil.initGlobalMsgListener();
    ChatUtil.initUnreadListener();
    _initData();
  }

  @override
  void dispose() {
    ChatUtil.removeGlobalMsgListener();
    ChatUtil.removeUnreadListener();
    super.dispose();
  }

  Future<void> _initData() async {
    await _getMeData();
    await _getChatList();
    await _getFriendList();
    await _loadRequests();
    await _loadNotifications();
    if (mounted) setState(() {});
  }

  /// 获取用户信息
  Future<void> _getMeData() async {
    final data = await Api().get("/api/auth/me");
    if (data.statusCode == 200) {
      final MeModel meModel = MeModel.fromJson(data.data['data']);
      await StorageManage.setMeModel(meModel);
    }
  }

  /// 聊天列表
  Future<void> _getChatList() async {
    await ChatUtil.fetchChatList();
  }

  /// 好友列表
  Future<void> _getFriendList() async {
    await ChatUtil.fetchFriendList();
  }

  /// 好友申请列表（含未读数）
  Future<void> _loadRequests() async {
    await ChatUtil.fetchFriendRequests();
  }

  /// 通知列表（含未读数）
  Future<void> _loadNotifications() async {
    await ChatUtil.fetchNotifications();
  }

  Widget _buildTabIcon(
    String asset,
    Color color, {
    int unreadCount = 0,
  }) {
    final icon = SvgPicture.asset(
      asset,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      width: 24,
      height: 24,
    );
    if (unreadCount <= 0) return icon;

    final text = unreadCount > 99 ? '99+' : '$unreadCount';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -10,
          top: -6,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: text.length > 2 ? 4 : 5),
            constraints: BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [HomePage(), AddressPage(), MinePage()],
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: ChatUtil.unreadCountNotifier,
        builder: (_, chatUnread, _) {
          return ValueListenableBuilder<int>(
            valueListenable: ChatUtil.addressUnreadNotifier,
            builder: (_, addressUnread, _) {
              return BottomNavigationBar(
                currentIndex: _currentIndex,
                selectedItemColor: Colors.green,
                backgroundColor: Color.fromRGBO(245, 245, 245, 1),
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: _buildTabIcon(
                      'assets/images/chat.svg',
                      Colors.grey,
                      unreadCount: chatUnread,
                    ),
                    activeIcon: _buildTabIcon(
                      'assets/images/chat.svg',
                      Colors.green,
                      unreadCount: chatUnread,
                    ),
                    label: '聊天',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildTabIcon(
                      'assets/images/address.svg',
                      Colors.grey,
                      unreadCount: addressUnread,
                    ),
                    activeIcon: _buildTabIcon(
                      'assets/images/address.svg',
                      Colors.green,
                      unreadCount: addressUnread,
                    ),
                    label: '通讯录',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/mine.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    ),
                    activeIcon: SvgPicture.asset(
                      'assets/images/mine.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.green, BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    ),
                    label: '我的',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
