import 'package:chat_demo/import.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ChatInitUtil().initSDK();

    if (UserPro.token.isNotEmpty &&
        UserPro.userId.isNotEmpty &&
        UserPro.userSig.isNotEmpty) {
      final res = await TencentImSDKPlugin.v2TIMManager.login(
        userID: UserPro.userId,
        userSig: UserPro.userSig,
      );
      if (res.code == 0 && mounted) {
        jumpAndRemovePage(context, AppPage());
        return;
      }
    }

    if (mounted) {
      jumpAndRemovePage(context, GuidePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
