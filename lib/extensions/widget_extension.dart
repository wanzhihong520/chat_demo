import 'package:chat_demo/import.dart';

extension WidgetExtension on Widget {
  Widget withExpanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  Widget withPadding({List<double> padding = const [0, 0, 0, 0]}) {
    return Padding(padding: EdgeInsets.only(left: padding[0], right: padding[1], top: padding[2], bottom: padding[3]), child: this);
  }

  Widget withOnTap(Function() onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  Widget withCenter(){
    return Center(child: this);
  }
}