import 'package:chat_demo/import.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _row(String title, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(title, style: FontStyleUtils.blackTitle),
            Spacer(),
            Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await ConfirmDialogUtil.show(
      context,
      message: '确定要退出登录吗？',
    );
    if (confirmed && context.mounted) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    ChatUtil.removeGlobalMsgListener();
    ChatUtil.removeUnreadListener();
    await Api().post('/api/auth/logout');
    final logoutRes = await TencentImSDKPlugin.v2TIMManager.logout();
    if (logoutRes.code != 0) {
      showToast('IM退出失败');
    }
    final sp = await SPUtil.getInstance();
    await sp.clear();
    AppProviders.auth.clear();
    AppProviders.chat.clear();
    AppProviders.contact.clear();
    if (context.mounted) {
      jumpAndRemovePage(context, GuidePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置', style: FontStyleUtils.blackTitle)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ContainerUtils(
            color: Colors.white,
            child: Column(
              children: [
                _row('个人资料', () => jumpPage(context, ProfilePage())),
                Divider(height: 1, color: Colors.grey[200]),
                _row('修改密码', () => jumpPage(context, ChangePasswordPage())),
                Divider(height: 1, color: Colors.grey[200]),
                _row('手机信息', () => jumpPage(context, PhoneInfoPage())),
              ],
            ),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            color: Colors.white,
            width: double.infinity,
            height: 54,
            child: Center(
              child: Text('退出登录', style: FontStyleUtils.blackTitle),
            ),
          ).withOnTap(() => _confirmLogout(context)),
        ],
      ),
    );
  }
}
