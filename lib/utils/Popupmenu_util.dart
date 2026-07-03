import 'package:chat_demo/import.dart';

class PopupMenuItemModel {
  final String icon;
  final String text;
  final VoidCallback? onTap;

  const PopupMenuItemModel({
    required this.icon,
    required this.text,
    this.onTap,
  });
}

class PopupmenuUtil extends StatelessWidget {
  final Widget icon;
  final List<PopupMenuItemModel> items;
  final Offset offset;
  final Color color;

  const PopupmenuUtil({
    super.key,
    required this.icon,
    required this.items,
    this.offset = const Offset(0, 50),
    this.color = const Color.fromRGBO(30, 30, 30, 1),
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: icon,
      offset: offset,
      color: color,
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem(
              onTap: item.onTap,
              child: Row(
                children: [
                  SvgPicture.asset(
                    item.icon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    item.text,
                    style: FontStyleUtils.whiteTitle,
                  ).withPadding(padding: [0, 4, 0, 0]),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
