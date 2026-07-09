import 'package:chat_demo/import.dart';

class ChatDetailPage extends StatefulWidget {
  final String receiver;
  const ChatDetailPage({super.key, required this.receiver});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isMore = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createTextMessageRes =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(
              text: _inputController.text, // 文本信息
            );
    if (createTextMessageRes.code == 0) {
      // 文本信息创建成功
      String? id = createTextMessageRes.data?.id;
      // 发送文本消息
      // 在sendMessage时，若只填写receiver则发个人用户单聊消息
      //                 若只填写groupID则发群组消息
      //                 若填写了receiver与groupID则发群内的个人用户，消息在群聊中显示，只有指定receiver能看见
      V2TimValueCallback<V2TimMessage> sendMessageRes = await TencentImSDKPlugin
          .v2TIMManager
          .getMessageManager()
          .sendMessage(
            id: id!, // 创建的messageid
            receiver: widget.receiver, // 接收人id
            groupID: "groupID", // 接收群组id
            priority: MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT, // 消息优先级
            onlineUserOnly:
                false, // 是否只有在线用户才能收到，如果设置为 true ，接收方历史消息拉取不到，常被用于实现“对方正在输入”或群组里的非重要提示等弱提示功能，该字段不支持 AVChatRoom。
            isExcludedFromUnreadCount: false, // 发送消息是否计入会话未读数
            isExcludedFromLastMessage: false, // 发送消息是否计入会话 lastMessage
            needReadReceipt:
                false, // 消息是否需要已读回执（只有 Group 消息有效，6.1 及以上版本支持，需要您购买旗舰版或企业版套餐）
            offlinePushInfo: OfflinePushInfo(), // 离线推送时携带的标题和内容
            cloudCustomData: "", // 消息云端数据，消息附带的额外的数据，存云端，消息的接收者可以访问到
            localCustomData:
                "", // 消息本地数据，消息附带的额外的数据，存本地，消息的接收者不可以访问到，App 卸载后数据丢失
          );
      if (sendMessageRes.code == 0) {
        // 发送成功
      }
    }
  }

  Widget _buildMoreItem({required String icon, required String text}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(14),
          child: SvgPicture.asset(icon),
        ),
        SizedBox(height: 4),
        Text(text, style: FontStyleUtils.blackBody),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('聊天详情')),
      body: Container(
        color: Color.fromRGBO(230, 230, 230, 1),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: SizedBox()),
              Column(
                children: [
                  ChatInputBar(
                    controller: _inputController,
                    focusNode: _focusNode,
                    hasText: _inputController.text.isNotEmpty,
                    onSend: () {},
                    onAddTap: () {
                      setState(() {
                        _isMore = !_isMore;
                        if (_isMore) _focusNode.unfocus();
                      });
                    },
                    onInputTap: () => setState(() => _isMore = false),
                  ),
                  if (_isMore)
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      color: Color.fromRGBO(247, 247, 247, 1),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildMoreItem(
                              icon: 'assets/images/photo.svg',
                              text: '相册',
                            );
                          }
                          if (index == 1) {
                            return _buildMoreItem(
                              icon: 'assets/images/video.svg',
                              text: '拍摄',
                            ).withOnTap(() async {
                              final file = await ImagePickerUtil.openCamera();
                              if (file != null) {
                                setState(() {
                                  _inputController.text = file.path;
                                });
                              }
                            });
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
