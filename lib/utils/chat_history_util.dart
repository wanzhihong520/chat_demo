import 'package:chat_demo/import.dart';
import 'package:tencent_cloud_chat_sdk/enum/image_types.dart';

class ChatHistoryUtil extends StatelessWidget {
  final V2TimMessage message;
  final bool? isSelf;

  const ChatHistoryUtil({super.key, required this.message, this.isSelf});

  bool get _isSelf => isSelf ?? message.sender == UserPro.userId;

  String _fullUrl(String url) {
    if (url.isEmpty) return '';
    return url.startsWith('http') ? url : BASE_URL + url;
  }

  String get _avatarUrl {
    if (_isSelf) return UserPro.meModel?.avatarUrl ?? '';
    return message.faceUrl ?? '';
  }

  void _previewImage(BuildContext context, String url, {bool isVideo = false}) {
    if (url.isEmpty) return;
    jumpPage(context, ImagePreviewPage(imageUrl: url, isVideo: isVideo));
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    if (content == null) return SizedBox.shrink();

    final avatarUrl = _fullUrl(_avatarUrl);
    final avatar = PortraitUtil(
      url: avatarUrl,
      width: 48,
      height: 48,
    ).withOnTap(() => _previewImage(context, avatarUrl));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: _isSelf
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _isSelf
            ? [Flexible(child: content), SizedBox(width: 8), avatar]
            : [avatar, SizedBox(width: 8), Flexible(child: content)],
      ),
    );
  }

  Widget? _buildContent(BuildContext context) {
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return _textBubble(message.textElem?.text ?? '');
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return _imageContent(context);
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return _mediaBubble(
          icon: Icons.mic,
          text: '${message.soundElem?.duration ?? 0}"',
        );
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return _videoBubble(
          context,
          message.videoElem?.videoPath ?? '',
          message.videoElem?.snapshotPath ?? '',
          message.videoElem?.duration ?? 0,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return _mediaBubble(
          icon: Icons.insert_drive_file,
          text: message.fileElem?.fileName ?? '文件',
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return _faceContent();
      default:
        return null;
    }
  }

  Widget _videoBubble(
    BuildContext context,
    String videoPath,
    String videoUrl,
    int duration,
  ) {
    final seconds = duration >= 1000 ? (duration / 1000).round() : duration;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final video = videoUrl.startsWith('http')
        ? Image.network(videoUrl, fit: BoxFit.cover)
        : Image.file(File(videoUrl), fit: BoxFit.cover);
    return IntrinsicWidth(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 240, maxHeight: 240),
              child: video,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: SvgPicture.asset(
                'assets/images/play.svg',
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Text(
              '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
              style: FontStyleUtils.whiteSmallBody,
            ),
          ),
        ],
      ),
    ).withOnTap(() => _previewImage(context, videoPath, isVideo: true));
  }

  Widget _textBubble(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isSelf ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        text,
        style: _isSelf ? FontStyleUtils.whiteBody : FontStyleUtils.blackBody,
      ),
    );
  }

  Widget _mediaBubble({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isSelf ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: _isSelf ? Colors.white : Colors.black54),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: _isSelf
                  ? FontStyleUtils.whiteBody
                  : FontStyleUtils.blackBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faceContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isSelf ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.emoji_emotions_outlined,
        size: 28,
        color: _isSelf ? Colors.white : Colors.black54,
      ),
    );
  }

  Widget _imageContent(BuildContext context) {
    final imageUrl = _resolveImageUrl();
    if (imageUrl == null || imageUrl.isEmpty) {
      return _textBubble('图片');
    }
    final image = imageUrl.startsWith('http')
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Image.file(File(imageUrl), fit: BoxFit.cover);
    return GestureDetector(
      onTap: () => _previewImage(context, imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 240, maxHeight: 240),
          child: image,
        ),
      ),
    );
  }

  String? _resolveImageUrl() {
    final path = message.imageElem?.path;
    if (path != null && path.isNotEmpty) return path;

    final list = message.imageElem?.imageList;
    if (list == null || list.isEmpty) return null;

    const types = [
      V2TIM_IMAGE_TYPE.V2TIM_IMAGE_TYPE_THUMB,
      V2TIM_IMAGE_TYPE.V2TIM_IMAGE_TYPE_LARGE,
      V2TIM_IMAGE_TYPE.V2TIM_IMAGE_TYPE_ORIGIN,
    ];
    for (final type in types) {
      for (final image in list) {
        if (image?.type == type) {
          final url = image?.localUrl ?? image?.url;
          if (url != null && url.isNotEmpty) return url;
        }
      }
    }
    return null;
  }
}
