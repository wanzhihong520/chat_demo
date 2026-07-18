import 'package:chat_demo/import.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      body: Consumer<ChatProvider>(
        builder: (_, chat, _) {
          final chatList = chat.chatList;
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
              final item = chatList[index];
              return ChatItemUtil(
                name: item.name,
                description: item.description,
                avatarUrl: item.avatarUrl,
                timeText: item.timeText,
                isAi: item.isAi,
                unreadCount: ChatUtil.unreadForChat(item),
                onTap: () {
                  if (item.isAi) {
                    jumpPage(context, AichatDetailPage(aiId: item.aiId));
                  } else if (item.isGroup) {
                    final gid = item.imGroupId ?? item.groupId ?? item.id;
                    jumpPage(
                      context,
                      ChatDetailPage(
                        groupId: gid,
                        imGroupId: gid,
                        title: item.name,
                        avatarUrl: item.avatarUrl,
                      ),
                    );
                  } else {
                    jumpPage(
                      context,
                      ChatDetailPage(
                        receiver: item.imUserId ?? item.id,
                        title: item.name,
                        avatarUrl: item.avatarUrl,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
