import 'package:chat_demo/import.dart';

class EditGroupNamePage extends StatefulWidget {
  final String groupId;
  final String name;

  const EditGroupNamePage({
    super.key,
    required this.groupId,
    required this.name,
  });

  @override
  State<EditGroupNamePage> createState() => _EditGroupNamePageState();
}

class _EditGroupNamePageState extends State<EditGroupNamePage> {
  late final TextEditingController _controller;
  late final String _original;

  bool get _edited => _controller.text.trim() != _original;

  @override
  void initState() {
    super.initState();
    _original = widget.name;
    _controller = TextEditingController(text: _original);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      showToast('群聊名称不能为空');
      return;
    }
    final ok = await ChatUtil.updateGroupName(
      groupId: widget.groupId,
      name: name,
    );
    if (!mounted) return;
    if (ok != null) {
      showToast('保存成功');
      backPage(context, ok);
    } else {
      showToast('保存失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, shape: Border()),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(24),
              children: [
                Center(
                  child: Text('修改群聊名称', style: FontStyleUtils.blackBoldTitle),
                ),
                SizedBox(height: 12),
                Text('修改群聊名称后，将在群内通知其他成员').withCenter(),
                SizedBox(height: 18),
                TextFieldUtils(
                  controller: _controller,
                  hintText: _original,
                  isField: true,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Center(
                child: ContainerUtils(
                  radius: 4,
                  height: 48,
                  width: 180,
                  color: _edited ? Colors.green : Colors.grey[300]!,
                  child: Text('完成', style: FontStyleUtils.whiteBody),
                ).withOnTap(_edited ? _save : () {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
