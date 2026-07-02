import 'package:chat_demo/import.dart';

class PopupmenuUtil extends StatelessWidget {
  const PopupmenuUtil({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: SvgPicture.asset('assets/images/add.svg', width: 28, height: 28),
      offset: Offset(0, 50),
      color: Color.fromRGBO(30, 30, 30, 1),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/chat.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              SizedBox(width: 12),
              Text(
                '发起群聊',
                style: FontStyleUtils.whiteTitle,
              ).withPadding(padding: [0, 4, 0, 0]),
            ],
          ),
          onTap: () {},
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/add_friend.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              SizedBox(width: 12),
              Text(
                '添加好友',
                style: FontStyleUtils.whiteTitle,
              ).withPadding(padding: [0, 4, 0, 0]),
            ],
          ),
          onTap: () {},
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/scan.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              SizedBox(width: 12),
              Text(
                '扫一扫',
                style: FontStyleUtils.whiteTitle,
              ).withPadding(padding: [0, 4, 0, 0]),
            ],
          ),
          onTap: () {
            showToast("当前功能暂未开放");
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/qr_code.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              SizedBox(width: 12),
              Text(
                '收款码',
                style: FontStyleUtils.whiteTitle,
              ).withPadding(padding: [0, 4, 0, 0]),
            ],
          ),
          onTap: () {
            showToast("当前功能暂未开放");
          },
        ),
      ],
    );
  }
}
