import 'package:chat_demo/import.dart';

class AichatDetailPage extends StatefulWidget {
  final String aiId;

  const AichatDetailPage({super.key, required this.aiId});

  @override
  State<AichatDetailPage> createState() => _AichatDetailPageState();
}

class _AichatDetailPageState extends State<AichatDetailPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AiMessageModel> _messages = [];
  AiSessionModel? _currentSession;
  bool _sending = false;
  bool _isMore = false;
  bool _isVoiceMode = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await _createSession();
    _inputController.addListener(() {
      setState(() {});
    });
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

  /// 创建会话
  Future<void> _createSession() async {
    final response = await Api().post(
      '/api/ai/sessions',
      data: {'aiId': widget.aiId, 'title': '新对话'},
    );
    final data = response.data;
    if (data is Map && data['code'] == 200) {
      setState(() {
        _currentSession = AiSessionModel.fromJson(data['data']);
        _messages = [];
      });
      showToast(data['message']);
    }
  }

  /// 选择会话
  Future<void> _selectSession(AiSessionModel session) async {
    setState(() {
      _currentSession = session;
      _messages = [];
    });
    await _loadMessages(session.sessionId);
  }

  /// 加载消息
  Future<void> _loadMessages(String sessionId) async {
    final response = await Api().get(
      '/api/ai/sessions/$sessionId/messages',
      params: {'page': 1, 'pageSize': 20},
    );
    final data = response.data;
    if (data is Map && data['code'] == 200) {
      setState(() {
        _messages = AiMessageListModel.fromJson(data['data']).list;
      });
      _scrollToBottom();
    }
  }

  /// 重命名会话
  Future<void> _renameSession() async {
    if (_currentSession == null) return;
    final controller = TextEditingController(text: _currentSession!.name);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('重命名'),
        backgroundColor: Colors.white,
        content: TextField(
          controller: controller,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: '请输入标题',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => backPage(context),
            child: Text('取消', style: FontStyleUtils.blackBody),
          ),
          TextButton(
            onPressed: () => backPage(context, controller.text.trim()),
            child: Text('确定', style: FontStyleUtils.blackBody),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    final sessionId = _currentSession!.sessionId;
    await Api().patch('/api/ai/sessions/$sessionId', data: {'title': title});
    setState(() {
      _currentSession = AiSessionModel(
        sessionId: _currentSession!.sessionId,
        aiId: _currentSession!.aiId,
        avatarUrl: _currentSession!.avatarUrl,
        name: title,
        description: _currentSession!.description,
        timeText: _currentSession!.timeText,
      );
    });
  }

  /// 删除会话
  Future<void> _deleteSession() async {
    if (_currentSession == null) return;
    await Api().delete('/api/ai/sessions/${_currentSession!.sessionId}');
    await _createSession();
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _sending || _currentSession == null) return;

    setState(() {
      _sending = true;
      _messages.add(
        AiMessageModel(id: '', role: 'user', content: content, createdAt: ''),
      );
      _messages.add(
        AiMessageModel(id: '', role: 'assistant', content: '', createdAt: ''),
      );
    });
    _inputController.clear();
    _scrollToBottom();

    final response = await Api().postStream(
      '/api/ai/sessions/${_currentSession!.sessionId}/messages/stream',
      data: {'content': content},
    );
    final stream = (response.data as ResponseBody).stream;
    var leftover = '';

    void handleLine(String line) {
      if (!line.startsWith('data: ')) return;
      final jsonStr = line.substring(6).trim();
      if (jsonStr.isEmpty) return;
      final event = jsonDecode(jsonStr) as Map<String, dynamic>;
      final type = event['type'];
      if (type == 'chunk') {
        setState(() {
          final last = _messages.last;
          _messages[_messages.length - 1] = AiMessageModel(
            id: last.id,
            role: last.role,
            content: last.content + (event['content'] ?? ''),
            createdAt: last.createdAt,
          );
        });
      } else if (type == 'done') {
        final doneData = event['data'];
        if (doneData is Map) {
          setState(() {
            _messages[_messages.length - 2] = AiMessageModel.fromJson(
              doneData['userMessage'],
            );
            _messages[_messages.length - 1] = AiMessageModel.fromJson(
              doneData['aiMessage'],
            );
            final sessionTitle = doneData['sessionTitle'];
            if (sessionTitle != null && _currentSession != null) {
              _currentSession = AiSessionModel(
                sessionId: _currentSession!.sessionId,
                aiId: _currentSession!.aiId,
                avatarUrl: _currentSession!.avatarUrl,
                name: sessionTitle.toString(),
                description: _currentSession!.description,
                timeText: _currentSession!.timeText,
              );
            }
          });
        }
      } else if (type == 'error') {
        showToast(event['message'] ?? '发送失败');
      }
    }

    await for (final bytes in stream) {
      leftover += utf8.decode(bytes);
      final lines = leftover.split('\n');
      leftover = lines.removeLast();
      for (final line in lines) {
        handleLine(line);
      }
    }
    if (leftover.isNotEmpty) handleLine(leftover);
    if (mounted) setState(() => _sending = false);
  }

  /// 滚动到最底部
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

  /// 显示会话列表
  Future<void> _showSessionList() async {
    final response = await Api().get(
      '/api/ai/sessions',
      params: {'aiId': widget.aiId},
    );
    final data = response.data;
    if (data is! Map || data['code'] != 200) return;
    final sessions = AiSessionListModel.fromJson(data['data']).list;
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            title: Text(session.name),
            trailing: session.timeText.isNotEmpty
                ? Text(session.timeText)
                : null,
            onTap: () {
              backPage(context);
              _selectSession(session);
            },
          );
        },
      ),
    );
  }

  String get _title => _currentSession?.name ?? '';

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
      appBar: AppBar(
        title: Text(_title),
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
                text: '开启新会话',
                onTap: _createSession,
              ),
              PopupMenuItemModel(
                icon: 'assets/images/chat_history.svg',
                text: '历史会话',
                onTap: _showSessionList,
              ),
              PopupMenuItemModel(
                icon: 'assets/images/rechristen.svg',
                text: '重命名',
                onTap: _renameSession,
              ),
              PopupMenuItemModel(
                icon: 'assets/images/delete.svg',
                text: '删除聊天',
                onTap: _deleteSession,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Color.fromRGBO(230, 230, 230, 1),
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          _currentSession == null ? '暂无对话，发送消息开始聊天' : '',
                          style: FontStyleUtils.blackBody,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return Align(
                            alignment: message.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: message.isUser
                                    ? Colors.green
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                message.content,
                                style: message.isUser
                                    ? FontStyleUtils.whiteBody
                                    : FontStyleUtils.blackBody,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromRGBO(220, 220, 220, 1),
                      ),
                      color: Color.fromRGBO(247, 247, 247, 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          _isVoiceMode
                              ? "assets/images/edit.svg"
                              : "assets/images/voice.svg",
                          width: 28,
                          height: 28,
                        ).withOnTap(_toggleVoiceMode),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(minHeight: 36),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _isVoiceMode
                                ? GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => showToast('当前功能暂未开发'),
                                    child: Center(
                                      child: Text(
                                        '按住说话',
                                        style: FontStyleUtils.blackBody,
                                      ),
                                    ),
                                  )
                                : TextFieldUtils(
                                    minLines: 1,
                                    maxLines: 5,
                                    onTap: () =>
                                        setState(() => _isMore = false),
                                    focusNode: _focusNode,
                                    controller: _inputController,
                                    hintText: '请输入内容',
                                  ),
                          ).withPadding(padding: [12, 12, 4, 4]),
                        ),
                        _inputController.text.isEmpty
                            ? SvgPicture.asset(
                                "assets/images/add.svg",
                                width: 28,
                                height: 28,
                              ).withOnTap(() {
                                setState(() {
                                  _isMore = !_isMore;
                                  if (_isMore) _focusNode.unfocus();
                                });
                              })
                            : ContainerUtils(
                                width: 54,
                                height: 32,
                                radius: 4,
                                color: Colors.green,
                                child: Text(
                                  "发送",
                                  style: FontStyleUtils.whiteTitle,
                                ),
                              ).withOnTap(_sendMessage),
                      ],
                    ),
                  ),
                  if (_isMore)
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                            ).withOnTap(() => showToast('当前功能暂未开发'));
                          }
                          if (index == 1) {
                            return _buildMoreItem(
                              icon: 'assets/images/video.svg',
                              text: '拍摄',
                            ).withOnTap(() => showToast('当前功能暂未开发'));
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
