import 'package:chat_demo/import.dart';

class ContainerUtils extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  final double radius;
  final String image;
  final Alignment alignment;
  final Widget child;
  final List<double> padding;
  const ContainerUtils({
    super.key,
    this.width,
    this.height,
    this.color = Colors.white,
    this.radius = 0,
    this.padding = const [0, 0, 0, 0],
    this.image = '',
    this.alignment = Alignment.center,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(
        left: padding[0],
        right: padding[1],
        top: padding[2],
        bottom: padding[3],
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        image: image.isNotEmpty
            ? DecorationImage(image: AssetImage(image), fit: BoxFit.cover)
            : null,
      ),
      width: width,
      height: height,
      child: child,
    );
  }
}
