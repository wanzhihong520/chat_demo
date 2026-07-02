import 'package:chat_demo/import.dart';

class AssetImageUtils extends StatelessWidget {
  final String path;
  final double radius;
  final double width;
  final double height;
  const AssetImageUtils({super.key, required this.path, this.radius = 4, this.width = 100, this.height = 100});


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(path, width: width, height: height),
    );
  }
}