class SearchModel {
  final String id;
  final String username;
  final String nickname;
  final String avatarUrl;
  final String imUserId;
  final bool isFriend;

  SearchModel({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatarUrl,
    required this.imUserId,
    required this.isFriend,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      imUserId: json['imUserId'] ?? '',
      isFriend: json['isFriend'] ?? false,
    );
  }
}
