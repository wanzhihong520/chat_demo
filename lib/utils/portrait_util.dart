import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PortraitUtil extends StatelessWidget {
  final String? url;
  final String? asset;
  final Color boxColor;
  final double radius;
  final double padding;
  final double width;
  final double height;

  const PortraitUtil({
    super.key,
    this.url,
    this.asset,
    this.boxColor = Colors.white,
    this.radius = 4,
    this.padding = 4,
    this.width = 48,
    this.height = 48,
  });

  bool get _isSvg => asset?.toLowerCase().endsWith('.svg') ?? false;

  @override
  Widget build(BuildContext context) {
    if (asset != null && asset!.isNotEmpty && _isSvg) {
      final size = width - padding * 2;
      return Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: SvgPicture.asset(
          asset!,
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(url ?? '', fit: BoxFit.contain),
      ),
    );
  }
}
