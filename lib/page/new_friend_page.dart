import 'package:chat_demo/import.dart';

class NewFriendPage extends StatefulWidget {
  const NewFriendPage({super.key});

  @override
  State<NewFriendPage> createState() => _NewFriendPageState();
}

class _NewFriendPageState extends State<NewFriendPage> {
  List<FriendRequestModel> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final data = await Api().get('/api/friends/requests');
    if (!mounted) return;
    if (data.statusCode == 200) {
      setState(() {
        _requests = FriendRequestListModel.fromJson(data.data['data']).list;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _acceptRequest(FriendRequestModel item) async {
    final response = await Api().post(
      '/api/friends/requests/${item.requestId}/accept',
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      setState(() {
        _requests.removeWhere((e) => e.requestId == item.requestId);
      });
      showToast('已同意');
      await ChatUtil.fetchFriendList();
      await ChatUtil.fetchChatList();
    } else {
      showToast(response.data['message'] ?? '操作失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新的朋友', style: FontStyleUtils.blackTitle),
        shape: Border(),
        actions: [
          TextButton(
            onPressed: () => jumpPage(context, SearchPage()),
            child: Text('添加好友', style: FontStyleUtils.blackBody),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(child: Text('暂无好友申请', style: FontStyleUtils.blackBody))
          : Column(
              children: [
                ContainerUtils(
                  alignment: Alignment.centerLeft,
                  padding: [12, 12, 8, 8],
                  color: Color.fromRGBO(230, 230, 230, 1),
                  child: Text('待同意', style: FontStyleUtils.blackTitle),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _requests.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, index) {
                      final item = _requests[index];
                      final url = item.from.avatarUrl;
                      final fullUrl = url.isEmpty
                          ? ''
                          : (url.startsWith('http') ? url : BASE_URL + url);
                      return Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 12, 12),
                        child: Row(
                          children: [
                            if (fullUrl.isNotEmpty)
                              PortraitUtil(url: fullUrl, width: 48, height: 48),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.from.nickname.isNotEmpty
                                        ? item.from.nickname
                                        : item.from.username,
                                    style: FontStyleUtils.blackTitle,
                                  ),
                                  if (item.wording.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        item.wording,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: FontStyleUtils.blackBody,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            ContainerUtils(
                              radius: 4,
                              padding: [12, 12, 4, 4],
                              color: Color.fromRGBO(220, 220, 220, 1),
                              child: Text('同意'),
                            ).withOnTap(() => _acceptRequest(item)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
