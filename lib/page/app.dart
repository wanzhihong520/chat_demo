import 'package:chat_demo/import.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tencent_map_flutter/tencent_map_flutter.dart' hide Position;

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
    await ChatUtil.fetchChatList();
    await ChatUtil.fetchFriendList();
    await ChatUtil.fetchFriendRequests();
    await ChatUtil.fetchNotifications();
    await requestLocationPermission();
  }

  Future requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('位置服务已关闭。');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('位置权限被拒绝。');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('位置权限已被永久拒绝，我们无法再次请求权限。');
    }
  }

  Future<void> _getMeData() async {
    final data = await Api().get("/api/auth/me");
    if (data.statusCode == 200) {
      final MeModel meModel = MeModel.fromJson(data.data['data']);
      await StorageManage.setMeModel(meModel);
    }
  }

  Widget _buildTabIcon(String asset, Color color, {int unreadCount = 0}) {
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
    final chatUnread = context.watch<ChatProvider>().unreadCount;
    final addressUnread = context.watch<ContactProvider>().addressUnread;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [HomePage(), AddressPage(), MinePage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/mine.svg',
              colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
