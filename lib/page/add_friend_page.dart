import 'package:chat_demo/import.dart';

class AddFriendPage extends StatefulWidget {
  final SearchModel searchModel;
  const AddFriendPage({super.key, required this.searchModel});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _greetingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _greetingController.text = '我是${UserPro.meModel?.nickname}';
  }

  Future<void> _sendGreeting() async {
    final response = await Api().post(
      '/api/friends/request',
      data: {
        'username': widget.searchModel.username,
        'wording': _greetingController.text.trim(),
      },
    );
    if (response.statusCode == 200) {
      showToast('发送成功');
    } else {
      showToast(response.data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: Border(),
        title: Text('申请添加好友', style: FontStyleUtils.blackTitle),
      ),
      body: ListView(
        children: [
          Text("打招呼内容", style: FontStyleUtils.grayBody),
          SizedBox(height: 8),
          ContainerUtils(
            width: double.infinity,
            padding: [12, 12, 4, 4],
            color: Color.fromRGBO(247, 247, 247, 1),
            radius: 10,
            child: TextFieldUtils(
              maxLines: 5,
              controller: _greetingController,
              hintText: '请输入打招呼内容',
            ),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            alignment: Alignment.center,
            width: double.infinity,
            height: 48,
            color: Colors.green,
            radius: 10,
            child: Text('发送', style: FontStyleUtils.whiteTitle),
          ).withOnTap(() {
            _sendGreeting();
            backPage(context);
          }),
        ],
      ).withPadding(padding: [24, 24, 12, 12]),
    );
  }
}
