class ChatListModel {
  final List<ChatModel> list;

  ChatListModel({required this.list});

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return ChatListModel(
      list: items
          .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'list': list.map((e) => e.toJson()).toList()};
  }
}

class ChatModel {
  final String id;
  final bool isAi;
  final bool isGroup;
  final String? imUserId;
  final String? groupId;
  final String? imGroupId;
  final String aiId;
  final String avatarUrl;
  final String name;
  final String description;
  final String timeText;

  ChatModel({
    required this.id,
    this.isAi = false,
    this.isGroup = false,
    this.imUserId,
    this.groupId,
    this.imGroupId,
    this.aiId = '',
    required this.avatarUrl,
    required this.name,
    required this.description,
    required this.timeText,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      isAi: json['isAi'] ?? false,
      isGroup: json['isGroup'] ?? false,
      imUserId: json['imUserId'],
      groupId: json['groupId'],
      imGroupId: json['imGroupId'],
      aiId: json['aiId'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      timeText: json['timeText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isAi': isAi,
      'isGroup': isGroup,
      if (imUserId != null) 'imUserId': imUserId,
      if (groupId != null) 'groupId': groupId,
      if (imGroupId != null) 'imGroupId': imGroupId,
      'aiId': aiId,
      'avatarUrl': avatarUrl,
      'name': name,
      'description': description,
      'timeText': timeText,
    };
  }
}
