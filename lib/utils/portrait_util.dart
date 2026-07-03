import 'package:flutter/material.dart';

class PortraitUtil extends StatelessWidget {
  final String url;
  final double radius;
  final double padding;
  final double width;
  final double height;
  const PortraitUtil({
    super.key,
    required this.url,
    this.radius = 4,
    this.padding = 4,
    this.width = 48,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: Image.network(url, fit: BoxFit.contain),
    );
  }
}
