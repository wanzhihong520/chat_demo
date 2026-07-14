import 'package:chat_demo/import.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imageUrl;
  final bool showAppBar;
  final bool isVideo;

  const ImagePreviewPage({
    super.key,
    required this.imageUrl,
    this.showAppBar = false,
    this.isVideo = false,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isLoading = false;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _controller = widget.imageUrl.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(widget.imageUrl))
          : VideoPlayerController.file(File(widget.imageUrl));
      _controller.initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _controller.play();
        });
        _controller.addListener(() {
          setState(() {});
        });
      });
    }
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

  ImageProvider? get _provider {
    if (widget.imageUrl.isEmpty) return null;
    if (widget.imageUrl.startsWith('http')) {
      return NetworkImage(widget.imageUrl);
    }
    final file = File(widget.imageUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return NetworkImage(BASE_URL + widget.imageUrl);
  }

  Widget _buildBody(BuildContext context) {
    final provider = _provider;
    if (provider == null) {
      return Center(child: Text('暂无图片', style: FontStyleUtils.whiteBody));
    }
    if (widget.isVideo) {
      if (!_controller.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return Stack(
        children: [
          PhotoView.customChild(
            childSize: Size(
              _controller.value.size.width,
              _controller.value.size.height,
            ),
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          Positioned(
            bottom: _isLoading ? 140 : 28,
            left: 64,
            right: 64,
            child: Text(
              textAlign: _isLoading ? TextAlign.center : TextAlign.left,
              '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
              style: _isLoading
                  ? TextStyle(fontSize: 20, color: Colors.white)
                  : FontStyleUtils.graySmallBody,
            ),
          ),
          Positioned(
            top: 48,
            left: 12,
            child: ContainerUtils(
              padding: [4, 4, 4, 4],
              radius: 60,
              color: Colors.grey.withValues(alpha: 0.5),
              child: Icon(Icons.close, color: Colors.white, size: 18),
            ).withOnTap(() => backPage(context)),
          ),
          Positioned(
            bottom: 0,
            left: 12,
            right: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ).withOnTap(() {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    if (_isPlaying) {
                      _controller.play();
                    } else {
                      _controller.pause();
                    }
                  });
                }),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: _isLoading ? 4 : 2,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: _isLoading ? 10 : 6,
                    ),
                  ),
                  child: Slider(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    value: _controller.value.position.inSeconds
                        .toDouble()
                        .clamp(
                          0,
                          _controller.value.duration.inSeconds.toDouble(),
                        ),
                    max: _controller.value.duration.inSeconds.toDouble().clamp(
                      1,
                      double.infinity,
                    ),
                    onChangeStart: (value) {
                      setState(() {
                        _isPlaying = false;
                        _isLoading = true;
                      });
                      _controller.pause();
                    },
                    onChanged: (value) {
                      _controller.seekTo(Duration(seconds: value.toInt()));
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        _isPlaying = true;
                        _isLoading = false;
                      });
                      _controller.play();
                    },
                  ),
                ).withExpanded(),
              ],
            ),
          ),
        ],
      );
    }
    return Stack(
      children: [
        PhotoView(
          imageProvider: provider,
          backgroundDecoration: BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          onTapUp: widget.showAppBar ? null : (_, _, _) => backPage(context),
        ),
        widget.showAppBar
            ? SizedBox.shrink()
            : Positioned(
                top: 48,
                left: 12,
                child: ContainerUtils(
                  padding: [4, 4, 4, 4],
                  radius: 60,
                  color: Colors.grey.withValues(alpha: 0.5),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ).withOnTap(() => backPage(context)),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: _buildBody(context)),
      );
    }
    if (widget.showAppBar) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          title: Text('头像', style: FontStyleUtils.whiteTitle),
          shape: Border(),
        ),
        body: _buildBody(context),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody(context)),
    );
  }
}
