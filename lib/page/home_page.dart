import 'package:chat_demo/import.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              PopupMenuItemModel(
                icon: 'assets/images/chat.svg',
                text: '发起群聊',
                onTap: () => jumpPage(context, CreateGroupPage()),
              ),
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
      body: ValueListenableBuilder<Map<String, int>>(
        valueListenable: ChatUtil.conversationUnreadNotifier,
        builder: (_, _, _) {
          return ValueListenableBuilder<List<ChatModel>>(
            valueListenable: ChatUtil.chatListNotifier,
            builder: (_, list, _) {
              final chatList = list.isNotEmpty ? list : UserPro.chatList;
              if (chatList.isEmpty) {
                return Center(
                  child: Text('暂无会话', style: FontStyleUtils.blackBody),
                );
              }
              return ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(height: 0.5, color: Colors.grey[300]),
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final chat = chatList[index];
                  return ChatItemUtil(
                    name: chat.name,
                    description: chat.description,
                    avatarUrl: chat.avatarUrl,
                    timeText: chat.timeText,
                    isAi: chat.isAi,
                    unreadCount: ChatUtil.unreadForChat(chat),
                    onTap: () {
                      if (chat.isAi) {
                        jumpPage(context, AichatDetailPage(aiId: chat.aiId));
                      } else if (chat.isGroup) {
                        jumpPage(
                          context,
                          ChatDetailPage(
                            groupId: chat.groupId ?? chat.id,
                            imGroupId: chat.imGroupId ?? chat.id,
                            title: chat.name,
                            avatarUrl: chat.avatarUrl,
                          ),
                        );
                      } else {
                        jumpPage(
                          context,
                          ChatDetailPage(
                            receiver: chat.imUserId ?? chat.id,
                            title: chat.name,
                            avatarUrl: chat.avatarUrl,
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
