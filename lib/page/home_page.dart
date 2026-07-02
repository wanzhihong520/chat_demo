import 'package:chat_demo/import.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FriendModel> get _friends => UserPro.friendsList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天'),
        actions: [
          PopupmenuUtil(),
        ],
      ),
      body: _friends.isEmpty
          ? Center(child: Text('暂无好友', style: FontStyleUtils.blackBody))
          : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend.avatarUrl.isNotEmpty
                        ? NetworkImage(friend.avatarUrl)
                        : null,
                    child: friend.avatarUrl.isEmpty
                        ? Text(friend.nickname.isNotEmpty
                            ? friend.nickname[0]
                            : '?')
                        : null,
                  ),
                  title: Text(friend.nickname),
                  subtitle: friend.isAi ? Text('AI') : null,
                );
              },
            ),
    );
  }
}
