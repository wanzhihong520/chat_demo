// ignore_for_file: use_build_context_synchronously

import 'package:chat_demo/import.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isSearch = false;
  late SearchModel _searchModel;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _search() async {
    var result = await Api().post(
      '/api/friends/search',
      data: jsonEncode({'username': _searchController.text}),
    );
    if (result.statusCode == 200) {
      setState(() {
        _searchModel = SearchModel.fromJson(result.data['data']);
      });
      jumpPage(context, FriendInfoPage(searchModel: _searchModel));
    } else {
      showToast(result.data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isSearch
        ? Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      ContainerUtils(
                        width: double.infinity,
                        height: 32,
                        color: Colors.white,
                        radius: 4,
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey,
                            ).withPadding(padding: [4, 4, 0, 0]),
                            TextFieldUtils(
                              onSubmitted: (value) {
                                _search();
                              },
                              textInputAction: TextInputAction.search,
                              focusNode: _searchFocusNode,
                              controller: _searchController,
                              hintText: '搜索 账号',
                              hintStyle: TextStyle(color: Colors.grey),
                            ).withExpanded(),
                          ],
                        ),
                      ).withExpanded(),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearch = false;
                          });
                        },
                        child: Text('取消', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ).withPadding(padding: [12, 12, 12, 12]),
                  _searchController.text.isNotEmpty
                      ? ContainerUtils(
                          color: Colors.white,
                          width: double.infinity,
                          height: 48,
                          child: Row(
                            children: [
                              ContainerUtils(
                                width: 36,
                                height: 36,
                                color: Colors.green,
                                padding: [6, 6, 6, 6],
                                child: SvgPicture.asset(
                                  "assets/images/add_friend.svg",
                                  colorFilter: ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "搜索:",
                                      style: FontStyleUtils.blackBody,
                                    ),
                                    TextSpan(
                                      text: _searchController.text.trim(),
                                      style: FontStyleUtils.themeBody,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).withPadding(padding: [12, 12, 0, 0]),
                        ).withOnTap(() {
                          _search();
                        })
                      : SizedBox.shrink(),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('添加好友', style: FontStyleUtils.blackTitle),
              backgroundColor: Colors.white,
            ),
            body: Container(
              color: Colors.white,
              child: Column(
                children: [
                  ContainerUtils(
                    color: Color.fromRGBO(240, 240, 240, 1),
                    radius: 4,
                    width: double.infinity,
                    height: 32,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          Text('搜索 账号', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ).withPadding(padding: [12, 12, 12, 12]).withOnTap(() {
                    setState(() {
                      _isSearch = true;
                      _searchFocusNode.requestFocus();
                    });
                  }),
                ],
              ),
            ),
          );
  }
}
