// ignore_for_file: use_build_context_synchronously

import 'package:chat_demo/import.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String username = _userNameController.text.trim();
    String password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      showToast('请输入账号和密码');
      return;
    }
    if (username.length < 6 || password.length < 6) {
      showToast('账号和密码长度不能小于6位');
      return;
    }
    final response = await Api().post(
      '/api/auth/login',
      data: {'username': username, 'password': password},
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
        showToast('登录成功');
        jumpAndRemovePage(context, AppPage());
      } else {
        showToast('登录失败');
      }
    } else {
      showToast(data['message'] ?? '登录失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(230, 230, 230, 1),
      appBar: AppBar(centerTitle: true, title: Text('登录'), shape: Border()),
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
              obscureText: true,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('没有账号？', style: FontStyleUtils.blackBody),
              Text('前往注册', style: FontStyleUtils.themeBody).withOnTap(() {
                jumpReplacementPage(context, RegistrationPage());
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
            child: Center(child: Text('登录', style: FontStyleUtils.whiteTitle)),
          ).withOnTap(() => _login()),
        ],
      ),
    );
  }
}
