import 'package:azlistview/azlistview.dart';
import 'package:lpinyin/lpinyin.dart';

class FriendListModel {
  final List<FriendModel> list;

  FriendListModel({required this.list});

  factory FriendListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return FriendListModel(
      list: items
          .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'list': list.map((e) => e.toJson()).toList()};
  }
}

class FriendModel extends ISuspensionBean{
  final String imUserId;
  final String name;
  final String avatarUrl;
  final bool isAi;
  final String tag;

  FriendModel({
    required this.imUserId,
    required this.name,
    required this.avatarUrl,
    required this.isAi,
    required this.tag,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? '';
    final tag = json['tag'] as String? ?? '';
    return FriendModel(
      imUserId: json['imUserId'] ?? '',
      name: name,
      avatarUrl: json['avatarUrl'] ?? '',
      isAi: json['isAi'] ?? false,
      tag: tag.isNotEmpty ? tag : tagFromName(name),
    );
  }

  static String tagFromName(String name) {
    if (name.isEmpty) return '#';
    final pinyin = PinyinHelper.getPinyinE(name);
    if (pinyin.isEmpty) return '#';
    final letter = pinyin.substring(0, 1).toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(letter)) return letter;
    return '#';
  }

  Map<String, dynamic> toJson() {
    return {
      'imUserId': imUserId,
      'name': name,
      'avatarUrl': avatarUrl,
      'isAi': isAi,
      'tag': tag,
    };
  }
  
  @override
  String getSuspensionTag() {
    return tag;
  }
}
