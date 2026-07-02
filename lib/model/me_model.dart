class MeModel {
  final String id;
  final String username;
  final String nickname;
  final String avatarUrl;
  final String imUserId;

  MeModel({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatarUrl,
    required this.imUserId,
  });

  factory MeModel.fromJson(Map<String, dynamic> json) {
    return MeModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      imUserId: json['imUserId'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'imUserId': imUserId,
    };
  }
}
