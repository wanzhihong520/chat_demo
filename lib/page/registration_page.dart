// ignore_for_file: use_build_context_synchronously

import 'package:chat_demo/import.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  Future<void> _register() async {
    String username = _userNameController.text.trim();
    String password = _passwordController.text.trim();
    String nickname = _nicknameController.text.trim();
    if (username.isEmpty || password.isEmpty || nickname.isEmpty) {
      showToast('请输入账号、密码和昵称');
      return;
    }
    if (username.length < 6 || password.length < 6) {
      showToast('账号和密码长度不能小于6位');
      return;
    }
    final response = await Api().post(
      '/api/auth/register',
      data: {'username': username, 'password': password, 'nickname': nickname},
    );
    final data = response.data;
    if (data is Map && data['code'] == 200) {
      final LoginModel loginModel = LoginModel.fromJson(data['data']);
      await StorageManage.setToken(loginModel.token);
      await StorageManage.setUserId(loginModel.im.userId);
      await StorageManage.setUserSig(loginModel.im.userSig);
      V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.login(
        userID: loginModel.im.userId,
        userSig: loginModel.im.userSig,
      );
      if (res.code == 0) {
        showToast('注册成功');
        jumpAndRemovePage(context, AppPage());
      } else {
        showToast('注册失败');
      }
    } else {
      showToast(data['message'] ?? '注册失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(230, 230, 230, 1),
      appBar: AppBar(centerTitle: true, title: Text('注册'), shape: Border()),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ContainerUtils(
            width: double.infinity,
            height: 48,
            radius: 8,
            color: Color.fromRGBO(245, 245, 245, 1),
            padding: [8, 8, 8, 8],
            child: TextFieldUtils(
              controller: _nicknameController,
              hintText: '请输入昵称',
            ),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            width: double.infinity,
            height: 48,
            radius: 8,
            color: Color.fromRGBO(245, 245, 245, 1),
            padding: [8, 8, 8, 8],
            child: TextFieldUtils(
              controller: _userNameController,
              hintText: '请输入账号',
            ),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            width: double.infinity,
            height: 48,
            radius: 8,
            color: Color.fromRGBO(245, 245, 245, 1),
            padding: [8, 8, 8, 8],
            child: TextFieldUtils(
              controller: _passwordController,
              hintText: '请输入密码',
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('已有账号？', style: FontStyleUtils.blackBody),
              Text('前往登录', style: FontStyleUtils.themeBody).withOnTap(() {
                jumpReplacementPage(context, LoginPage());
              }),
            ],
          ),
          SizedBox(height: 12),
          ContainerUtils(
            width: double.infinity,
            height: 48,
            radius: 8,
            color: Colors.green,
            padding: [8, 8, 8, 8],
            child: Center(child: Text('注册', style: FontStyleUtils.whiteTitle)),
          ).withOnTap(() => _register()),
        ],
      ),
    );
  }
}
