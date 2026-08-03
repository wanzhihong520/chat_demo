import 'package:chat_demo/import.dart';

class MomentsPage extends StatelessWidget {
  const MomentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('朋友圈', style: FontStyleUtils.blackTitle)),
      body: Center(child: Text('暂无朋友圈', style: FontStyleUtils.blackBody)),
    );
  }
}
