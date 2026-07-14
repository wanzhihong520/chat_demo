class CreateGroupResult {  final String groupId;
  final String imGroupId;
  final String name;
  final String avatarUrl;
  final int memberCount;

  CreateGroupResult({
    required this.groupId,
    required this.imGroupId,
    required this.name,
    required this.avatarUrl,
    required this.memberCount,
  });

  factory CreateGroupResult.fromJson(Map<String, dynamic> json) {
    return CreateGroupResult(
      groupId: json['groupId'] ?? json['imGroupId'] ?? '',
      imGroupId: json['imGroupId'] ?? json['groupId'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      memberCount: json['memberCount'] ?? 0,
    );
  }
}

class GroupListModel {
  final List<GroupListItemModel> list;

  GroupListModel({required this.list});

  factory GroupListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return GroupListModel(
      list: items
          .map((e) => GroupListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GroupListItemModel {
  final String groupId;
  final String imGroupId;
  final String name;
  final String avatarUrl;
  final String role;
  final String lastMessage;
  final int lastMessageTime;

  GroupListItemModel({
    required this.groupId,
    required this.imGroupId,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory GroupListItemModel.fromJson(Map<String, dynamic> json) {
    return GroupListItemModel(
      groupId: json['groupId'] ?? json['imGroupId'] ?? '',
      imGroupId: json['imGroupId'] ?? json['groupId'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      role: json['role'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] ?? 0,
    );
  }
}

class GroupMemberModel {
  final String userId;
  final String username;
  final String nickname;
  final String name;
  final String gender;
  final String imUserId;
  final String avatarUrl;
  final String role;
  final String joinedAt;

  GroupMemberModel({
    required this.userId,
    required this.username,
    required this.nickname,
    required this.name,
    required this.gender,
    required this.imUserId,
    required this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  String get displayName {
    if (name.isNotEmpty) return name;
    if (nickname.isNotEmpty) return nickname;
    return username;
  }

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId']?.toString() ?? '',
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      imUserId: json['imUserId'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      role: json['role'] ?? '',
      joinedAt: json['joinedAt'] ?? '',
    );
  }
}

class GroupDetailModel {
  final String groupId;
  final String imGroupId;
  final String name;
  final String avatarUrl;
  final String ownerUserId;
  final String ownerImUserId;
  final int memberCount;
  final List<GroupMemberModel> members;
  final String createdAt;

  GroupDetailModel({
    required this.groupId,
    required this.imGroupId,
    required this.name,
    required this.avatarUrl,
    required this.ownerUserId,
    required this.ownerImUserId,
    required this.memberCount,
    required this.members,
    required this.createdAt,
  });

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    final items = json['members'] as List? ?? [];
    return GroupDetailModel(
      groupId: json['groupId'] ?? '',
      imGroupId: json['imGroupId'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      ownerUserId: json['ownerUserId']?.toString() ?? '',
      ownerImUserId: json['ownerImUserId'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      members: items
          .map((e) => GroupMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
