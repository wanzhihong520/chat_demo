// ignore_for_file: use_build_context_synchronously

import 'package:chat_demo/import.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      showToast('请输入原密码和新密码');
      return;
    }
    if (oldPassword.length < 6 || newPassword.length < 6) {
      showToast('密码长度不能小于6位');
      return;
    }
    final response = await Api().post(
      '/api/auth/password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      showToast('修改成功');
      backPage(context);
    } else {
      showToast(response.data['message'] ?? '修改失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(230, 230, 230, 1),
      appBar: AppBar(
        centerTitle: true,
        title: Text('修改密码', style: FontStyleUtils.blackTitle),
      ),
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
              controller: _oldPasswordController,
              hintText: '请输入原密码',
              keyboardType: TextInputType.number,
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
              controller: _newPasswordController,
              hintText: '请输入新密码',
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            width: double.infinity,
            height: 48,
            radius: 8,
            color: Colors.green,
            padding: [8, 8, 8, 8],
            child: Center(
              child: Text('确认修改', style: FontStyleUtils.whiteTitle),
            ),
          ).withOnTap(_changePassword),
        ],
      ),
    );
  }
}
