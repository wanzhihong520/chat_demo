import 'package:chat_demo/import.dart';
import 'package:video_compress/video_compress.dart';

class ChatDetailPage extends StatefulWidget {
  final String receiver;
  const ChatDetailPage({super.key, required this.receiver});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isMore = false;
  List<V2TimMessage> _messageList = [];

  @override
  void initState() {
    super.initState();
    _initMessage();
    _inputController.addListener(() => setState(() {}));
    ChatUtil.onNewMessage = _handleNewMessage;
  }

  @override
  void dispose() {
    if (ChatUtil.onNewMessage == _handleNewMessage) {
      ChatUtil.onNewMessage = null;
    }
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNewMessage(V2TimMessage message) {
    if (message.sender == UserPro.userId) return;
    final peerId = message.userID ?? message.sender ?? '';
    if (peerId != widget.receiver) return;
    if (!mounted) return;
    setState(() => _messageList.add(message));
    _scrollToBottom();
  }

  /// 初始化消息
  Future<void> _initMessage() async {
    V2TimValueCallback<List<V2TimMessage>> getHistoryMessageListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .getHistoryMessageList(
              getType: HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
              userID: widget.receiver,
              groupID: '',
              count: 20,
              lastMsgID: null,
              lastMsgSeq: -1,
              messageTypeList: [],
            );
    if (getHistoryMessageListRes.code == 0) {
      setState(() {
        _messageList = getHistoryMessageListRes.data?.reversed.toList() ?? [];
      });
    }
  }

  /// 创建成功后统一发送、上屏、同步会话
  Future<void> _sendById(String id) async {
    final message = await ChatUtil.sendToC2C(id: id, receiver: widget.receiver);
    if (message == null || !mounted) return;
    setState(() => _messageList.add(message));
    ChatUtil.syncLastMessage(imUserId: widget.receiver, message: message);
    _scrollToBottom();
  }

  Future<void> _sendText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createTextMessage(text: text);
    if (created.code != 0 || created.data?.id == null) return;
    _inputController.clear();
    await _sendById(created.data!.id!);
  }

  Future<void> _sendImage(String path) async {
    final source = File(path);
    final compressed = await FlutterImageCompress.compressAndGetFile(
      source.path,
      '${source.parent.path}/chat_${DateTime.now().millisecondsSinceEpoch}.jpeg',
      quality: 80,
    );
    final imagePath = compressed?.path ?? path;
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createImageMessage(imagePath: imagePath);
    if (created.code != 0 || created.data?.id == null) return;
    setState(() => _isMore = false);
    await _sendById(created.data!.id!);
  }

  Future<void> _sendVideo(String path) async {
    final source = File(path);
    final compressed = await VideoCompress.compressVideo(
      source.path,
      quality: VideoQuality.MediumQuality,
    );
    final videoPath = compressed?.path ?? path;
    final coverPath = await VideoCompress.getFileThumbnail(source.path);
    final created = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createVideoMessage(
          videoFilePath: videoPath,
          type: 'video/mp4',
          duration: compressed!.duration?.toInt() ?? 0,
          snapshotPath: coverPath.path,
        );
    if (created.code != 0 || created.data?.id == null) return;
    setState(() => _isMore = false);
    await _sendById(created.data!.id!);
  }

  Future<void> _pickFromAlbum() async {
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: RequestType.common,
        maxAssets: 1,
      ),
    );
    if (assets == null || assets.isEmpty) return;
    final file = await assets.first.file;
    if (file == null) return;
    if (assets.first.type == AssetType.video) {
      await _sendVideo(file.path);
    } else {
      await _sendImage(file.path);
    }
  }

  Future<void> _pickFromCamera() async {
    final file = await ImagePickerUtil.openCamera();
    if (file == null) return;
    await _sendImage(file.path);
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
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
              ListView.builder(
                controller: _scrollController,
                itemCount: _messageList.length,
                itemBuilder: (context, index) {
                  return ChatHistoryUtil(
                    message: _messageList[index],
                    isSelf: _messageList[index].sender == UserPro.userId,
                  );
                },
              ).withExpanded(),
              Column(
                children: [
                  ChatInputBar(
                    controller: _inputController,
                    focusNode: _focusNode,
                    hasText: _inputController.text.isNotEmpty,
                    onSend: _sendText,
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
                            ).withOnTap(_pickFromAlbum);
                          }
                          if (index == 1) {
                            return _buildMoreItem(
                              icon: 'assets/images/video.svg',
                              text: '拍摄',
                            ).withOnTap(_pickFromCamera);
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
