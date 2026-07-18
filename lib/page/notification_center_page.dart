import 'package:chat_demo/import.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  @override
  void initState() {
    super.initState();
    _onEnter();
  }

  Future<void> _onEnter() async {
    await ChatUtil.markNotificationsRead();
    await ChatUtil.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(237, 237, 237, 1),
      appBar: AppBar(
        title: Text('通知中心', style: FontStyleUtils.blackTitle),
        shape: Border(),
      ),
      body: Consumer<ContactProvider>(
        builder: (_, contact, _) {
          final list = contact.notifications;
          if (list.isEmpty) {
            return Center(
              child: Text('暂无通知', style: FontStyleUtils.blackBody),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: FontStyleUtils.blackTitle,
                          ),
                        ),
                        if (item.timeText.isNotEmpty)
                          Text(
                            item.timeText,
                            style: FontStyleUtils.graySmallBody,
                          ),
                      ],
                    ),
                    if (item.content.isNotEmpty) ...[
                      SizedBox(height: 6),
                      Text(item.content, style: FontStyleUtils.blackBody),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
