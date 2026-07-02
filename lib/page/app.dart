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
    _initData();
  }

  Future<void> _initData() async {
    await _getMeData();
    await _getFriends();
    if (mounted) setState(() {});
  }

  /// 获取用户信息
  Future<void> _getMeData() async {
    final data = await Api().get("/api/auth/me");
    if (data.statusCode == 200) {
      final MeModel meModel = MeModel.fromJson(data.data);
      await StorageManage.setMeModel(meModel);
    }
  }

  /// 好友列表
  Future<void> _getFriends() async {
    final data = await Api().get("/api/friends");
    if (data.statusCode == 200) {
      final friendsList = FriendsListModel.fromJson(data.data['list']).list;
      await StorageManage.setFriendsList(friendsList);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: SvgPicture.asset(
              'assets/images/chat.svg',
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/chat.svg',
              colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            label: '聊天',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/address.svg',
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/address.svg',
              colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
              width: 24,
              height: 24,
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
