import 'package:chat_demo/import.dart';
import 'package:tencent_cloud_chat_sdk/enum/image_types.dart';
import 'package:tencent_map_flutter/tencent_map_flutter.dart';
import 'package:latlong2/latlong.dart' as geo;

class _SoundPlayHelper {
  static final player = AudioPlayer();
  static final playingId = ValueNotifier<String?>(null);
  static var _listenerAttached = false;

  static void _ensureListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playingId.value = null;
      }
    });
  }

  static Future<void> toggle(String msgId, String? path) async {
    if (path == null || path.isEmpty) return;
    _ensureListener();
    if (playingId.value == msgId) {
      await player.stop();
      playingId.value = null;
      return;
    }
    await player.stop();
    playingId.value = msgId;
    if (path.startsWith('http')) {
      await player.setUrl(path);
    } else {
      await player.setFilePath(path);
    }
    await player.play();
  }
}

class _SoundBubble extends StatelessWidget {
  final V2TimMessage message;
  final bool isSelf;

  const _SoundBubble({required this.message, required this.isSelf});

  String? get _soundPath {
    final path = message.soundElem?.path;
    if (path != null && path.isNotEmpty) return path;
    final url = message.soundElem?.url;
    if (url == null || url.isEmpty) return null;
    return url.startsWith('http') ? url : BASE_URL + url;
  }

  String get _msgId =>
      message.msgID ?? message.id ?? message.timestamp.toString();

  @override
  Widget build(BuildContext context) {
    final duration = message.soundElem?.duration ?? 0;
    return ValueListenableBuilder<String?>(
      valueListenable: _SoundPlayHelper.playingId,
      builder: (context, playingId, _) {
        final isPlaying = playingId == _msgId;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelf ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.stop_circle_outlined : Icons.mic,
                size: 20,
                color: isSelf ? Colors.white : Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                '$duration"',
                style: isSelf
                    ? FontStyleUtils.whiteBody
                    : FontStyleUtils.blackBody,
              ),
            ],
          ),
        ).withOnTap(() => _SoundPlayHelper.toggle(_msgId, _soundPath));
      },
    );
  }
}

class _VideoBubble extends StatefulWidget {
  final V2TimMessage message;

  const _VideoBubble({required this.message});

  @override
  State<_VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<_VideoBubble> {
  String _coverUrl = '';
  String _playUrl = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  String _pick(List<String?> candidates) {
    for (final c in candidates) {
      if (c == null || c.isEmpty) continue;
      if (c.startsWith('http')) return c;
      if (File(c).existsSync()) return c;
    }
    for (final c in candidates) {
      if (c != null && c.isNotEmpty && c.startsWith('http')) return c;
    }
    return '';
  }

  Future<void> _resolve() async {
    final elem = widget.message.videoElem;
    var cover = _pick([
      elem?.localSnapshotUrl,
      elem?.snapshotPath,
      elem?.snapshotUrl,
    ]);
    var play = _pick([elem?.localVideoUrl, elem?.videoPath, elem?.videoUrl]);

    if (mounted) {
      setState(() {
        _coverUrl = cover;
        _playUrl = play;
      });
    }
    if (cover.isNotEmpty && play.isNotEmpty) return;
    if (!mounted) return;

    setState(() => _loading = true);
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getMessageOnlineUrl(message: widget.message);
    if (!mounted) return;

    if (res.code == 0) {
      final online = res.data?.videoElem;
      cover = _pick([
        cover,
        online?.localSnapshotUrl,
        online?.snapshotUrl,
        online?.snapshotPath,
      ]);
      play = _pick([
        play,
        online?.localVideoUrl,
        online?.videoUrl,
        online?.videoPath,
      ]);
    }
    setState(() {
      _coverUrl = cover;
      _playUrl = play;
      _loading = false;
    });
  }

  Widget _buildCover() {
    if (_coverUrl.isEmpty) {
      return Container(
        width: 160,
        height: 120,
        color: Colors.black12,
        alignment: Alignment.center,
        child: _loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.videocam, color: Colors.black38),
      );
    }
    if (_coverUrl.startsWith('http')) {
      return Image.network(_coverUrl, fit: BoxFit.contain);
    }
    return Image.file(File(_coverUrl), fit: BoxFit.contain);
  }

  Future<void> _openPreview(BuildContext context) async {
    if (_playUrl.isEmpty) await _resolve();
    if (!context.mounted || _playUrl.isEmpty) return;
    jumpPage(context, ImagePreviewPage(imageUrl: _playUrl, isVideo: true));
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.message.videoElem?.duration ?? 0;
    final snapshotWidth = widget.message.videoElem?.snapshotWidth ?? 0;
    final snapshotHeight = widget.message.videoElem?.snapshotHeight ?? 0;
    final aspectRatio = snapshotWidth > 0 && snapshotHeight > 0
        ? snapshotWidth / snapshotHeight
        : null;
    final cover = aspectRatio == null
        ? _buildCover()
        : SizedBox(
            width: aspectRatio >= 1 ? 240 : 240 * aspectRatio,
            height: aspectRatio >= 1 ? 240 / aspectRatio : 240,
            child: _buildCover(),
          );
    final seconds = duration >= 1000 ? (duration / 1000).round() : duration;
    final m = seconds ~/ 60;
    final s = seconds % 60;

    return IntrinsicWidth(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 240, maxHeight: 240),
              child: cover,
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
    ).withOnTap(() => _openPreview(context));
  }
}

class ChatHistoryUtil extends StatelessWidget {
  final V2TimMessage message;
  final bool? isSelf;
  final bool isGroup;

  const ChatHistoryUtil({
    super.key,
    required this.message,
    this.isSelf,
    this.isGroup = false,
  });

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

  String get _senderName {
    if (_isSelf) return UserPro.meModel?.nickname ?? '';
    final remark = message.friendRemark;
    if (remark != null && remark.isNotEmpty) return remark;
    final nameCard = message.nameCard;
    if (nameCard != null && nameCard.isNotEmpty) return nameCard;
    final nick = message.nickName;
    if (nick != null && nick.isNotEmpty) return nick;
    for (final friend in UserPro.friendList) {
      if (friend.imUserId == message.sender) return friend.name;
    }
    return message.sender ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
      final text = ChatUtil.groupTipsPreview(message);
      if (text.isEmpty) return SizedBox.shrink();
      return _tipsText(text);
    }

    // 后端激活文字（邀请/退群文案）按 tips 灰条展示，避免普通气泡
    if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      final text = message.textElem?.text?.trim() ?? '';
      if (ChatUtil.isGroupSystemText(text)) {
        return _tipsText(text);
      }
    }

    final content = _buildContent(context);
    if (content == null) return SizedBox.shrink();

    final avatarUrl = _fullUrl(_avatarUrl);
    final avatar = PortraitUtil(
      url: avatarUrl,
      width: 48,
      height: 48,
    ).withOnTap(() => _previewImage(context, avatarUrl));

    final messageBody = isGroup
        ? Column(
            crossAxisAlignment: _isSelf
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (_senderName.isNotEmpty) ...[
                Text(_senderName, style: FontStyleUtils.graySmallBody),
                SizedBox(height: 4),
              ],
              content,
            ],
          )
        : content;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: _isSelf
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _isSelf
            ? [Flexible(child: messageBody), SizedBox(width: 8), avatar]
            : [avatar, SizedBox(width: 8), Flexible(child: messageBody)],
      ),
    );
  }

  Widget _tipsText(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(child: Text(text, style: FontStyleUtils.graySmallBody)),
    );
  }

  Widget? _buildContent(BuildContext context) {
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return _textBubble(message.textElem?.text ?? '');
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return _imageContent(context);
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return _SoundBubble(message: message, isSelf: _isSelf);
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return _VideoBubble(message: message);
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return _mediaBubble(
          icon: Icons.insert_drive_file,
          text: message.fileElem?.fileName ?? '文件',
          onTap: () {},
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return _faceContent();
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return _locationBubble(context);
      default:
        return null;
    }
  }

  Widget _locationBubble(BuildContext context) {
    final location = message.locationElem;

    if (location == null) {
      return const SizedBox.shrink();
    }

    final latitude = (location.latitude as num?)?.toDouble() ?? 0.0;
    final longitude = (location.longitude as num?)?.toDouble() ?? 0.0;
    final desc = (location.desc ?? '').trim();
    final bubbleWidth = MediaQuery.sizeOf(context).width * 0.6;
    return Stack(
      children: [
        ContainerUtils(
          color: Colors.white,
          radius: 4,
          width: bubbleWidth,
          padding: [8, 8, 8, 8],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                desc.isEmpty ? '位置' : desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontStyleUtils.blackBody,
              ),
              _LocationMapPreview(latitude: latitude, longitude: longitude),
            ],
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.transparent).withOnTap(() {
            _showMapChooser(context, latitude, longitude, desc);
          }),
        ),
      ],
    );
  }

  Future<void> _showMapChooser(
    BuildContext context,
    double latitude,
    double longitude,
    String desc,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in const [
              ('腾讯地图', 'tencent'),
              ('百度地图', 'baidu'),
              ('高德地图', 'amap'),
            ]) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.$1, textAlign: TextAlign.center),
                onTap: () => Navigator.pop(context, item.$2),
              ),
              const Divider(height: 1, thickness: 0.5),
            ],
            Container(height: 12, color: Colors.grey.shade300),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('取消', textAlign: TextAlign.center),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final name = Uri.encodeComponent(desc.isEmpty ? '目的地' : desc);
    final appUrl = switch (choice) {
      'tencent' => Uri.parse(
        'qqmap://map/routeplan?type=drive&to=$name&tocoord=$latitude,$longitude',
      ),
      'baidu' => Uri.parse(
        'baidumap://map/direction?destination=name:$name|latlng:$latitude,$longitude&mode=driving',
      ),
      _ => Uri.parse(
        'amapuri://route/plan/?dlat=$latitude&dlon=$longitude&dname=$name&dev=0&t=0',
      ),
    };
    final webUrl = switch (choice) {
      'tencent' => Uri.parse(
        'https://apis.map.qq.com/uri/v1/routeplan?type=drive&to=$name&tocoord=$latitude,$longitude',
      ),
      'baidu' => Uri.parse(
        'https://api.map.baidu.com/dir?destination=$latitude,$longitude&destination_name=$name&mode=driving&output=html',
      ),
      _ => Uri.parse(
        'https://uri.amap.com/navigation?to=$longitude,$latitude,$name&mode=car&coordinate=gaode',
      ),
    };
    try {
      final opened = await launchUrl(
        appUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!opened)
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('无法打开地图导航')));
        }
      }
    }
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

  Widget _mediaBubble({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
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
    ).withOnTap(onTap);
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

class _LocationMapPreview extends StatefulWidget {
  final double latitude;
  final double longitude;

  const _LocationMapPreview({required this.latitude, required this.longitude});

  @override
  State<_LocationMapPreview> createState() => _LocationMapPreviewState();
}

class _LocationMapPreviewState extends State<_LocationMapPreview> {
  TencentMapController? _controller;
  late final TencentMap _map;

  @override
  void initState() {
    super.initState();
    // TencentMap's didUpdateWidget reads a late mapId. Keep one widget
    // instance so chat list rebuilds cannot update it before native creation.
    _map = TencentMap(
      androidTexture: true,
      compassEnabled: false,
      myLocationEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      rotateGesturesEnabled: false,
      skewGesturesEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        _moveToMessageLocation();
      },
    );
  }

  void _moveToMessageLocation() {
    final controller = _controller;
    if (controller == null) return;
    controller.moveCamera(
      CameraPosition(
        position: geo.LatLng(widget.latitude, widget.longitude),
        zoom: 16,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _LocationMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _moveToMessageLocation();
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The preview is intentionally read-only; the chat bubble is not a map editor.
          _map,
          IgnorePointer(
            child: Icon(Icons.location_on, color: Colors.green, size: 36),
          ),
        ],
      ),
    );
  }
}
