class FriendsListModel {
  final List<FriendModel> list;

  FriendsListModel({required this.list});

  factory FriendsListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return FriendsListModel(
      list: items
          .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'list': list.map((e) => e.toJson()).toList()};
  }
}

class FriendModel {
  final String imUserId;
  final String nickname;
  final String avatarUrl;
  final bool isAi;

  FriendModel({
    required this.imUserId,
    required this.nickname,
    required this.avatarUrl,
    required this.isAi,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      imUserId: json['imUserId'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isAi: json['isAi'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imUserId': imUserId,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'isAi': isAi,
    };
  }
}
