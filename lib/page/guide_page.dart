import 'package:chat_demo/import.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContainerUtils(
        width: double.infinity,
        height: double.infinity,
        image: 'assets/images/bg_login.jpg',
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerUtils(
              width: 120,
              height: 48,
              radius: 8,
              color: Colors.green,
              child: Center(
                child: Text('登录', style: FontStyleUtils.whiteTitle),
              ),
            ).withOnTap(() {
              jumpPage(context, LoginPage());
            }),
            ContainerUtils(
              width: 120,
              height: 48,
              radius: 8,
              color: Colors.white,
              child: Center(
                child: Text('注册', style: FontStyleUtils.blackTitle),
              ),
            ).withOnTap(() {
              jumpPage(context, RegistrationPage());
            }),
          ],
        ).withPadding(padding: [16, 16, 32, 32]),
      ),
    );
  }
}
