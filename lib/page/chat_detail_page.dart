import 'dart:async';

import 'package:chat_demo/import.dart';
import 'package:path_provider/path_provider.dart';

class ChatDetailPage extends StatefulWidget {
  final String? receiver;
  final String? groupId;
  final String? imGroupId;
  final String? title;
  final String? avatarUrl;

  const ChatDetailPage({
    super.key,
    this.receiver,
    this.groupId,
    this.imGroupId,
    this.title,
    this.avatarUrl,
  });

  bool get isGroup =>
      (imGroupId != null && imGroupId!.isNotEmpty) ||
      (groupId != null && groupId!.isNotEmpty && receiver == null);

  String get _imGroupId => imGroupId ?? groupId ?? '';

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final record = AudioRecorder();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  bool _isCancel = false;
  Offset? _startOffset;
  Timer? _timer;
  int _duration = 0;
  bool _isMore = false;
  bool _isVoiceMode = false;
  List<V2TimMessage> _messageList = [];
  GroupDetailModel? _groupDetail;

  String get _appBarTitle {
    if (!widget.isGroup) return widget.title ?? '聊天详情';
    final name = _groupDetail?.name ?? widget.title ?? '聊天详情';
    final count = _groupDetail?.memberCount ?? 0;
    return ChatUtil.groupTitleWithCount(name, count);
  }

  Future<void> _loadGroupDetail() async {
    final id = widget.groupId ?? widget._imGroupId;
    if (id.isEmpty) return;
    final detail = await ChatUtil.fetchGroupDetail(id);
    if (!mounted) return;
    setState(() => _groupDetail = detail);
  }

  @override
  void initState() {
    super.initState();
    _initMessage();
    if (widget.isGroup) _loadGroupDetail();
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
    record.dispose();
    super.dispose();
  }

  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
      if (_isVoiceMode) {
        _isMore = false;
        _focusNode.unfocus();
      }
    });
    if (!_isVoiceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _handleNewMessage(V2TimMessage message) {
    if (message.elemType != MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS &&
        message.sender == UserPro.userId) {
      return;
    }
    if (widget.isGroup) {
      final groupId = message.groupID ?? '';
      if (groupId != widget._imGroupId) return;
    } else {
      final peerId = message.userID ?? message.sender ?? '';
      if (peerId != widget.receiver) return;
    }
    if (!mounted) return;
    setState(() => _messageList.add(message));
    _scrollToBottom();
  }

  Future<void> _initMessage() async {
    await ChatUtil.markConversationRead(
      receiver: widget.isGroup ? null : widget.receiver,
      imGroupId: widget.isGroup ? widget._imGroupId : null,
    );
    final list = await ChatUtil.fetchHistory(
      userID: widget.isGroup ? null : widget.receiver,
      groupID: widget.isGroup ? widget._imGroupId : null,
    );
    if (!mounted) return;
    setState(() => _messageList = list);
  }

  void _onMessageSent(V2TimMessage? message) {
    if (message == null || !mounted) return;
    setState(() => _messageList.add(message));
    if (widget.isGroup) {
      ChatUtil.syncGroupLastMessage(
        imGroupId: widget._imGroupId,
        message: message,
      );
    } else {
      ChatUtil.syncLastMessage(imUserId: widget.receiver!, message: message);
    }
    _scrollToBottom();
  }

  Future<void> _sendText() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    _onMessageSent(
      await ChatUtil.sendText(
        text,
        receiver: widget.isGroup ? null : widget.receiver,
        groupID: widget.isGroup ? widget._imGroupId : null,
      ),
    );
  }

  Future<void> _pickFromAlbum() async {
    final message = await ChatUtil.pickFromAlbum(
      context,
      receiver: widget.isGroup ? null : widget.receiver,
      groupID: widget.isGroup ? widget._imGroupId : null,
    );
    if (message != null) setState(() => _isMore = false);
    _onMessageSent(message);
  }

  Future<void> _pickFromCamera() async {
    final message = await ChatUtil.pickFromCamera(
      receiver: widget.isGroup ? null : widget.receiver,
      groupID: widget.isGroup ? widget._imGroupId : null,
    );
    if (message != null) setState(() => _isMore = false);
    _onMessageSent(message);
  }

  Future<void> _startRecording(Offset position) async {
    if (!await record.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    setState(() {
      _isRecording = true;
      _duration = 0;
      _isCancel = false;
      _startOffset = position;
    });
    await record.start(const RecordConfig(), path: path);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _duration++);
    });
  }

  Future<void> _recordMoveUpdate(Offset position) async {
    if (_startOffset == null) return;
    if (position.dy - _startOffset!.dy < -100) {
      setState(() => _isCancel = true);
    } else {
      setState(() => _isCancel = false);
    }
  }

  Future<void> _stopRecording() async {
    if (_isCancel) {
      record.cancel();
      _timer?.cancel();
      _startOffset = null;
      setState(() => _isRecording = false);
      return;
    }
    final path = await record.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _isCancel = false;
      _startOffset = null;
    });
    if (path == null) return;
    _onMessageSent(
      await ChatUtil.sendSound(
        path,
        duration: _duration,
        receiver: widget.isGroup ? null : widget.receiver,
        groupID: widget.isGroup ? widget._imGroupId : null,
      ),
    );
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

  Future<void> _openChatInfo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatInfoPage(
          isGroup: widget.isGroup,
          name: ChatUtil.groupBaseName(
            _groupDetail?.name ?? widget.title ?? '聊天详情',
          ),
          avatarUrl: widget.avatarUrl ?? '',
          receiver: widget.receiver,
          groupId: widget.groupId ?? widget._imGroupId,
          imGroupId: widget._imGroupId,
        ),
      ),
    );
    if (!mounted) return;
    if (result == 'deleted') {
      backPage(context);
      return;
    }
    if (result == true) {
      setState(() => _messageList = []);
    }
    if (widget.isGroup) await _loadGroupDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            onPressed: _openChatInfo,
            icon: Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
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
                        isGroup: widget.isGroup,
                      );
                    },
                  ).withExpanded(),
                  Column(
                    children: [
                      ChatInputBar(
                        controller: _inputController,
                        focusNode: _focusNode,
                        hasText: _inputController.text.isNotEmpty,
                        isVoiceMode: _isVoiceMode,
                        onVoiceTap: _toggleVoiceMode,
                        onSend: _sendText,
                        onRecordStart: _startRecording,
                        onRecordMoveUpdate: _recordMoveUpdate,
                        onRecordStop: _stopRecording,
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
          if (_isRecording) ChatVoiceRecordWidget(isCancel: _isCancel),
        ],
      ),
    );
  }
}
