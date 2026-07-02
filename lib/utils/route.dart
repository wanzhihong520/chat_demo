import 'package:chat_demo/import.dart';

//跳转页面
void jumpPage(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

//返回页面
void backPage(BuildContext context) {
  Navigator.pop(context);
}

//跳转页面并移除当前页面
void jumpReplacementPage(BuildContext context, Widget page) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
}

//跳转页面并移除所有页面
void jumpAndRemovePage(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => page), (route) => false);
}