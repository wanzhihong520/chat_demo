import 'package:chat_demo/import.dart';

class TextFieldUtils extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  const TextFieldUtils({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      cursorColor: Colors.black,  
      decoration: InputDecoration(hintText: hintText, border: InputBorder.none),
    );
  }
}
