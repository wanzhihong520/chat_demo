import 'package:chat_demo/import.dart';

/// 普通聊天详情页输入栏（含 + 展开更多）
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback onSend;
  final void Function(Offset position) onRecordStart;
  final void Function(Offset position) onRecordMoveUpdate;
  final VoidCallback onRecordStop;
  final VoidCallback onAddTap;
  final VoidCallback onInputTap;
  final bool isVoiceMode;
  final VoidCallback onVoiceTap;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onSend,
    required this.onRecordStart,
    required this.onRecordMoveUpdate,
    required this.onRecordStop,
    required this.onAddTap,
    required this.onInputTap,
    this.isVoiceMode = false,
    required this.onVoiceTap,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isVoiceMode ? "assets/images/edit.svg" : "assets/images/voice.svg",
            width: 28,
            height: 28,
          ).withOnTap(onVoiceTap),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 36),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: isVoiceMode
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        onRecordStart(details.globalPosition);
                      },
                      onPanUpdate: (details) {
                        onRecordMoveUpdate(details.globalPosition);
                      },
                      onPanEnd: (details) {
                        onRecordStop();
                      },
                      child: Center(
                        child: Text('按住说话', style: FontStyleUtils.blackBody),
                      ),
                    )
                  : TextFieldUtils(
                      onTap: onInputTap,
                      focusNode: focusNode,
                      controller: controller,
                      hintText: '请输入内容',
                      minLines: 1,
                      maxLines: 5,
                    ),
            ).withPadding(padding: [12, 12, 4, 4]),
          ),
          hasText && !isVoiceMode
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

class ChatVoiceRecordWidget extends StatelessWidget {
  final bool isCancel;
  const ChatVoiceRecordWidget({super.key, this.isCancel = false});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Stack(
            children: [
              Center(
                child: Lottie.asset(
                  'assets/lottie/sound.json',
                  width: 120,
                  height: 120,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: 188,
                left: 120,
                right: 120,
                child: ContainerUtils(
                  radius: 24,
                  width: 180,
                  height: 48,
                  color: isCancel ? Colors.white : Color.fromRGBO(87, 87, 87, 1),
                  child: Center(
                    child: Text('上拉取消', style: isCancel ? FontStyleUtils.blackTitle : FontStyleUtils.whiteTitle),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/arc_bg.png",
                  height: 88,
                  fit: BoxFit.fill,
                  color: Color.fromRGBO(87, 87, 87, 1),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Text('松开发送', style: FontStyleUtils.whiteTitle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
