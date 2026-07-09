import 'package:chat_demo/import.dart';

/// 普通聊天详情页输入栏（含 + 展开更多）
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onAddTap;
  final VoidCallback onInputTap;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onSend,
    required this.onAddTap,
    required this.onInputTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(220, 220, 220, 1)),
        color: Color.fromRGBO(247, 247, 247, 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SvgPicture.asset(
            "assets/images/voice.svg",
            width: 28,
            height: 28,
          ).withOnTap(() => showToast('当前功能暂未开发')),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 36),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextFieldUtils(
                onTap: onInputTap,
                focusNode: focusNode,
                controller: controller,
                hintText: '请输入内容',
                minLines: 1,
                maxLines: 5,
              ),
            ).withPadding(padding: [12, 12, 4, 4]),
          ),
          hasText
              ? ContainerUtils(
                  width: 54,
                  height: 32,
                  radius: 4,
                  color: Colors.green,
                  child: Text("发送", style: FontStyleUtils.whiteTitle),
                ).withOnTap(onSend)
              : SvgPicture.asset(
                  "assets/images/add.svg",
                  width: 28,
                  height: 28,
                ).withOnTap(onAddTap),
        ],
      ),
    );
  }
}
