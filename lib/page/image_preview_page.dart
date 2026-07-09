import 'package:chat_demo/import.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  final bool showAppBar;

  const ImagePreviewPage({
    super.key,
    required this.imageUrl,
    this.showAppBar = false,
  });

  String get _fullUrl {
    if (imageUrl.isEmpty) return '';
    return imageUrl.startsWith('http') ? imageUrl : BASE_URL + imageUrl;
  }

  Widget _buildImage() {
    return Image.network(
      _fullUrl,
      width: double.infinity,
      fit: BoxFit.fitWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = Center(child: _buildImage());

    if (showAppBar) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          title: Text('头像', style: FontStyleUtils.whiteTitle),
          shape: Border(),
        ),
        body: image,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => backPage(context),
      child: Scaffold(backgroundColor: Colors.black, body: image),
    );
  }
}
