import 'package:chat_demo/import.dart';

class FriendInfoPage extends StatefulWidget {
  final SearchModel searchModel;
  const FriendInfoPage({super.key, required this.searchModel});

  @override
  State<FriendInfoPage> createState() => _FriendInfoPageState();
}

class _FriendInfoPageState extends State<FriendInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, shape: Border()),
      body: ListView(
        children: [
          ContainerUtils(
            width: double.infinity,
            height: 100,
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortraitUtil(
                  url: widget.searchModel.avatarUrl,
                  width: 64,
                  height: 64,
                  radius: 4,
                ).withOnTap(() {
                  jumpPage(
                    context,
                    ImagePreviewPage(imageUrl: widget.searchModel.avatarUrl),
                  );
                }),
                SizedBox(width: 12),
                Text(
                  widget.searchModel.nickname,
                  style: FontStyleUtils.blackBoldTitle,
                ),
              ],
            ).withPadding(padding: [12, 12, 12, 0]),
          ),
          SizedBox(height: 12),
          ContainerUtils(
            width: double.infinity,
            height: 54,
            child: Center(
              child: Text(
                widget.searchModel.isFriend ? '发送消息' : '添加到通讯录',
                style: FontStyleUtils.themeText,
              ),
            ),
          ).withOnTap(() {
            if (widget.searchModel.isFriend) {
              jumpPage(context, ChatDetailPage(receiver: widget.searchModel.id));
            } else {
              jumpPage(context, AddFriendPage(searchModel: widget.searchModel));
            }
          }),
        ],
      ),
    );
  }
}
