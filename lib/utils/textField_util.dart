import 'package:chat_demo/import.dart';

class TextFieldUtils extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final TextStyle? hintStyle;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? minLines;
  final int? maxLines;
  const TextFieldUtils({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.onTap,
    this.hintStyle,
    this.textInputAction,
    this.onSubmitted,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: minLines,
      maxLines: maxLines,
      onTap: onTap,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      controller: controller,
      cursorColor: Colors.black,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        border: InputBorder.none,
        hintStyle: hintStyle,
      ),
    );
  }
}
