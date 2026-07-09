import 'package:chat_demo/import.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('收藏', style: FontStyleUtils.blackTitle)),
      body: Center(child: Text('暂无收藏', style: FontStyleUtils.blackBody)),
    );
  }
}
