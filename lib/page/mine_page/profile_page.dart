import 'package:chat_demo/import.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _getMeData() async {
    final data = await Api().get('/api/auth/me');
    if (!mounted) return;
    if (data.statusCode == 200) {
      final meModel = MeModel.fromJson(data.data['data']);
      await StorageManage.setMeModel(meModel);
      setState(() {});
    }
  }

  Future<void> _pickAssets() async {
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: 1,
      ),
    );
    if (assets == null || assets.isEmpty) return;
    final asset = assets.first;
    final file = await asset.file;
    if (file == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪头像',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
      ],
    );
    if (cropped == null) return;
    final xFile = await FlutterImageCompress.compressAndGetFile(
      File(cropped.path).path,
      "${file.parent.path}/avatar.jpeg",
      quality: 80,
    );
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        xFile!.path,
        filename: 'avatar.jpeg',
      ),
    });
    final response = await Api().post(
      '/api/auth/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      showToast('上传成功');
      await _getMeData();
    } else {
      showToast(response.data['message'] ?? '上传失败');
    }
  }

  Widget _row(String label, Widget value, {VoidCallback? onTap}) {
    final row = Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: FontStyleUtils.blackTitle),
          Spacer(),
          value,
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_right, color: Colors.grey),
        ],
      ),
    );
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = UserPro.meModel;

    return Scaffold(
      appBar: AppBar(title: Text('个人资料', style: FontStyleUtils.blackTitle)),
      body: me == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _row(
                  '头像',
                  PortraitUtil(
                    url: me.avatarUrl,
                    width: 48,
                    height: 48,
                  ).withOnTap(
                    () => jumpPage(
                      context,
                      ImagePreviewPage(
                        imageUrl: me.avatarUrl,
                        showAppBar: true,
                      ),
                    ),
                  ),
                  onTap: () {
                    _pickAssets();
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                _row(
                  '用户名',
                  Text(me.nickname, style: FontStyleUtils.blackBody),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNicknamePage(),
                      ),
                    );
                    await _getMeData();
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                _row(
                  '性别',
                  Text(me.gender, style: FontStyleUtils.blackBody),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditGenderPage()),
                    );
                    await _getMeData();
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                _row(
                  '账号',
                  Text(me.username, style: FontStyleUtils.blackBody),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: me.username));
                    showToast('已将账号复制到剪贴板');
                  },
                ),
              ],
            ),
    );
  }
}
