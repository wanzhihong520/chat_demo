import 'package:chat_demo/import.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List<GroupListItemModel> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    final list = await ChatUtil.fetchGroupList();
    if (!mounted) return;
    setState(() {
      _groups = list;
      _loading = false;
    });
  }

  String _fullAvatarUrl(String url) {
    if (url.isEmpty) return '';
    return url.startsWith('http') ? url : BASE_URL + url;
  }

  Widget _buildItem(GroupListItemModel group) {
    final avatarUrl = _fullAvatarUrl(group.avatarUrl);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        jumpPage(
          context,
          ChatDetailPage(
            groupId: group.groupId,
            imGroupId: group.imGroupId,
            title: group.name,
            avatarUrl: avatarUrl,
          ),
        );
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            group.avatarUrl.isEmpty
                ? PortraitUtil(
                    width: 48,
                    height: 48,
                    radius: 4,
                    asset: 'assets/images/group.svg',
                    boxColor: Colors.green,
                    padding: 10,
                  )
                : PortraitUtil(url: avatarUrl, width: 48, height: 48, radius: 4),
            SizedBox(width: 12),
            Expanded(
              child: Text(group.name, style: FontStyleUtils.blackTitle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text('${_groups.length}个群聊', style: FontStyleUtils.grayBody),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('群聊', style: FontStyleUtils.blackTitle),
        shape: Border(),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView.separated(
              itemCount: _groups.length + 1,
              separatorBuilder: (_, __) => Divider(
                height: 0.5,
                thickness: 0.5,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                if (index == _groups.length) return _buildFooter();
                return _buildItem(_groups[index]);
              },
            ),
    );
  }
}
