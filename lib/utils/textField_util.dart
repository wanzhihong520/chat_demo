import 'package:chat_demo/import.dart';

class TextFieldUtils extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  const TextFieldUtils({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      focusNode: focusNode,
      keyboardType: keyboardType,
      controller: controller,
      cursorColor: Colors.black,  
      decoration: InputDecoration(hintText: hintText, border: InputBorder.none),
    );
  }
}
