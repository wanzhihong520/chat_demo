import 'package:chat_demo/import.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Widget _menuRow(String icon, String title, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24),
            SizedBox(width: 12),
            Text(title, style: FontStyleUtils.blackTitle),
            Spacer(),
            Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => jumpPage(context, ProfilePage()),
            child: ContainerUtils(
              color: Colors.white,
              padding: [12, 12, MediaQuery.of(context).padding.top, 12],
              width: double.infinity,
              height: 180,
              child: Row(
                children: [
                  PortraitUtil(
                    url: UserPro.meModel!.avatarUrl,
                    width: 64,
                    height: 64,
                  ),
                  SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        UserPro.meModel!.nickname,
                        style: FontStyleUtils.blackBoldTitle,
                      ),
                      Text(
                        "账号：${UserPro.meModel!.username}",
                        style: FontStyleUtils.blackBody,
                      ),
                    ],
                  ).withExpanded(),
                  Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            color: Colors.white,
            child: Column(
              children: [
                _menuRow(
                  'assets/images/favorite.png',
                  '收藏',
                  () => jumpPage(context, FavoritePage()),
                ),
                Divider(height: 1, color: Colors.grey[200], indent: 52),
                _menuRow(
                  'assets/images/moments.png',
                  '朋友圈',
                  () => jumpPage(context, MomentsPage()),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            color: Colors.white,
            child: _menuRow(
              'assets/images/settings.png',
              '设置',
              () => jumpPage(context, SettingsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
