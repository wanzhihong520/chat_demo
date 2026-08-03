import 'package:chat_demo/import.dart';

class EditNicknamePage extends StatefulWidget {
  const EditNicknamePage({super.key});

  @override
  State<EditNicknamePage> createState() => _EditNicknamePageState();
}

class _EditNicknamePageState extends State<EditNicknamePage> {
  late final TextEditingController _controller;
  late final String _original;

  bool get _edited => _controller.text.trim() != _original;

  @override
  void initState() {
    super.initState();
    _original = UserPro.meModel?.nickname ?? '';
    _controller = TextEditingController(text: _original);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty) {
      showToast('昵称不能为空');
      return;
    }
    final response = await Api().post(
      '/api/auth/profile',
      data: {'nickname': nickname},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      final data = await Api().get('/api/auth/me');
      if (data.statusCode == 200) {
        await StorageManage.setMeModel(MeModel.fromJson(data.data['data']));
      }
      if (!mounted) return;
      showToast('保存成功');
      backPage(context);
    } else {
      showToast(response.data['message'] ?? '保存失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更改名字', style: FontStyleUtils.blackTitle),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _edited ? _save : null,
                child: ContainerUtils(
                  radius: 4,
                  height: 32,
                  padding: [12, 12, 0, 0],
                  color: _edited ? Colors.green : Colors.grey,
                  child: Text('保存', style: FontStyleUtils.whiteBody),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: _original,
              hintStyle: FontStyleUtils.grayBody,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text('好名字可以让朋友更容易记住你。', style: FontStyleUtils.grayBody),
        ],
      ),
    );
  }
}
