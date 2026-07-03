import 'package:chat_demo/import.dart';
import 'package:chat_demo/utils/imagePicker_util.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isMore = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildMoreItem({required String icon, required String text}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(14),
          child: SvgPicture.asset(icon),
        ),
        SizedBox(height: 4),
        Text(text, style: FontStyleUtils.blackBody),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('聊天详情')),
      body: Container(
        color: Color.fromRGBO(230, 230, 230, 1),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: SizedBox()),
              Column(
                children: [
                  ChatInputBar(
                    controller: _inputController,
                    focusNode: _focusNode,
                    hasText: _inputController.text.isNotEmpty,
                    onSend: () {},
                    onAddTap: () {
                      setState(() {
                        _isMore = !_isMore;
                        if (_isMore) _focusNode.unfocus();
                      });
                    },
                    onInputTap: () => setState(() => _isMore = false),
                  ),
                  if (_isMore)
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      color: Color.fromRGBO(247, 247, 247, 1),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildMoreItem(
                              icon: 'assets/images/photo.svg',
                              text: '相册',
                            );
                          }
                          if (index == 1) {
                            return _buildMoreItem(
                              icon: 'assets/images/video.svg',
                              text: '拍摄',
                            ).withOnTap(() async {
                              final file = await ImagePickerUtil.openCamera();
                              if (file != null) {
                                setState(() {
                                  _inputController.text = file.path;
                                });
                              }
                            });
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
