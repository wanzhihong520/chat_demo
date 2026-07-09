import 'package:chat_demo/import.dart';

class EditGenderPage extends StatefulWidget {
  const EditGenderPage({super.key});

  @override
  State<EditGenderPage> createState() => _EditGenderPageState();
}

class _EditGenderPageState extends State<EditGenderPage> {
  late String _gender;

  @override
  void initState() {
    super.initState();
    _gender = UserPro.meModel?.gender ?? '男';
  }

  Future<void> _save() async {
    final response = await Api().post(
      '/api/auth/profile',
      data: {'gender': _gender},
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

  Widget _genderItem(String label) {
    final selected = _gender == label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _gender = label),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(label, style: FontStyleUtils.blackTitle),
            Spacer(),
            if (selected)
              Icon(Icons.check, color: Colors.green, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置性别', style: FontStyleUtils.blackTitle),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _save,
                child: ContainerUtils(
                  radius: 4,
                  height: 32,
                  padding: [12, 12, 0, 0],
                  color: Colors.green,
                  child: Text('完成', style: FontStyleUtils.whiteBody),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _genderItem('男'),
          Divider(height: 1, color: Colors.grey[200]),
          _genderItem('女'),
        ],
      ),
    );
  }
}
