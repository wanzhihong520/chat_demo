import 'package:chat_demo/import.dart';

class ChatItemUtil extends StatefulWidget {
  static const Color selectedColor = Color.fromRGBO(220, 220, 220, 1);
  static const Color aiColor = Color.fromRGBO(230, 230, 230, 1);
  static const Color normalColor = Colors.white;

  final ChatModel chat;
  final VoidCallback onTap;

  const ChatItemUtil({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  State<ChatItemUtil> createState() => _ChatItemUtilState();
}

class _ChatItemUtilState extends State<ChatItemUtil> {
  bool _highlighted = false;

  Color get _backgroundColor {
    if (_highlighted) return ChatItemUtil.selectedColor;
    return widget.chat.isAi ? ChatItemUtil.aiColor : ChatItemUtil.normalColor;
  }

  void _setHighlighted(bool value) {
    if (_highlighted == value) return;
    setState(() {
      _highlighted = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setHighlighted(true),
      onTapUp: (_) => _setHighlighted(false),
      onTapCancel: () => _setHighlighted(false),
      onLongPressEnd: (_) => _setHighlighted(false),
      onTap: () {
        _setHighlighted(false);
        widget.onTap();
      },
      child: Container(
        color: _backgroundColor,
        padding: EdgeInsets.only(left: 16, top: 12, bottom: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortraitUtil(
              url: BASE_URL + widget.chat.avatarUrl,
              radius: 4,
              width: 48,
              height: 48,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.chat.name,
                                style: FontStyleUtils.blackTitle,
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.chat.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontStyleUtils.blackBody,
                              ),
                            ],
                          ),
                        ),
                        if (widget.chat.timeText.isNotEmpty)
                          Text(
                            widget.chat.timeText,
                            style: FontStyleUtils.blackBody,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(height: 0.5, thickness: 0.5, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
