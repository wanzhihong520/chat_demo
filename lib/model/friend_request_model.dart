class FriendRequestListModel {
  final List<FriendRequestModel> list;

  FriendRequestListModel({required this.list});

  factory FriendRequestListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return FriendRequestListModel(
      list: items
          .map((e) => FriendRequestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FriendRequestModel {
  final String requestId;
  final String wording;
  final String createdAt;
  final FriendRequestFrom from;

  FriendRequestModel({
    required this.requestId,
    required this.wording,
    required this.createdAt,
    required this.from,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requestId: json['requestId']?.toString() ?? '',
      wording: json['wording'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      from: FriendRequestFrom.fromJson(json['from'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class FriendRequestFrom {
  final String username;
  final String nickname;
  final String avatarUrl;

  FriendRequestFrom({
    required this.username,
    required this.nickname,
    required this.avatarUrl,
  });

  factory FriendRequestFrom.fromJson(Map<String, dynamic> json) {
    return FriendRequestFrom(
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}
