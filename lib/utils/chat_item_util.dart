import 'package:chat_demo/import.dart';

class ChatItemUtil extends StatefulWidget {
  static const Color selectedColor = Colors.white;
  static const Color aiColor = Color.fromRGBO(230, 230, 230, 1);
  static const Color normalColor = Colors.white;

  final String? name;
  final String? description;
  final String? avatarUrl;
  final String? asset;
  final Color? boxColor;
  final String? timeText;
  final bool isAi;
  final VoidCallback? onTap;

  const ChatItemUtil({
    super.key,
    this.name,
    this.description,
    this.avatarUrl,
    this.asset,
    this.boxColor,
    this.timeText,
    this.isAi = false,
    this.onTap,
  });

  @override
  State<ChatItemUtil> createState() => _ChatItemUtilState();
}

class _ChatItemUtilState extends State<ChatItemUtil> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.description ?? '';
    final timeText = widget.timeText ?? '';
    final url = widget.avatarUrl ?? '';
    final fullUrl = url.isEmpty
        ? ''
        : (url.startsWith('http') ? url : BASE_URL + url);

    return GestureDetector(
      onTapDown: (_) => setState(() => _highlighted = true),
      onTapUp: (_) => setState(() => _highlighted = false),
      onTapCancel: () => setState(() => _highlighted = false),
      onTap: () {
        setState(() => _highlighted = false);
        widget.onTap?.call();
      },
      child: Container(
        color: _highlighted
            ? ChatItemUtil.selectedColor
            : widget.isAi
            ? ChatItemUtil.aiColor
            : ChatItemUtil.normalColor,
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            if (widget.asset != null && widget.asset!.isNotEmpty)
              PortraitUtil(
                width: 40,
                height: 40,
                padding: 8,
                asset: widget.asset,
                boxColor: widget.boxColor ?? Colors.white,
              )
            else if (fullUrl.isNotEmpty)
              PortraitUtil(url: fullUrl, width: 48, height: 48),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name ?? '', style: FontStyleUtils.blackTitle),
                  if (description.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontStyleUtils.blackBody,
                      ),
                    ),
                ],
              ),
            ),
            if (timeText.isNotEmpty)
              Text(timeText, style: FontStyleUtils.blackBody),
          ],
        ),
      ),
    );
  }
}
