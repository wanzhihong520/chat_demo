import 'package:chat_demo/import.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatModel> get _chatList => UserPro.chatList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天'),
        actions: [
          PopupmenuUtil(
            icon: SvgPicture.asset(
              'assets/images/add.svg',
              width: 28,
              height: 28,
            ),
            items: [
              PopupMenuItemModel(icon: 'assets/images/chat.svg', text: '发起群聊'),
              PopupMenuItemModel(
                icon: 'assets/images/add_friend.svg',
                text: '添加好友',
                onTap: () => jumpPage(context, SearchPage()),
              ),
              PopupMenuItemModel(
                icon: 'assets/images/scan.svg',
                text: '扫一扫',
                onTap: () => showToast('当前功能暂未开放'),
              ),
              PopupMenuItemModel(
                icon: 'assets/images/qr_code.svg',
                text: '收款码',
                onTap: () => showToast('当前功能暂未开放'),
              ),
            ],
          ),
        ],
      ),
      body: _chatList.isEmpty
          ? Center(child: Text('暂无会话', style: FontStyleUtils.blackBody))
          : ListView.separated(
              separatorBuilder: (context, index) =>
                  Divider(height: 0.5, color: Colors.grey[400]),
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                final chat = _chatList[index];
                return ChatItemUtil(
                  name: chat.name,
                  description: chat.description,
                  avatarUrl: chat.avatarUrl,
                  timeText: chat.timeText,
                  isAi: chat.isAi,
                  onTap: () {
                    if (chat.isAi) {
                      jumpPage(context, AichatDetailPage(aiId: chat.aiId));
                    } else {
                      jumpPage(context, ChatDetailPage(receiver: chat.id));
                    }
                  },
                );
              },
            ),
    );
  }
}
