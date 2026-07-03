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
  final String aiId;
  final String imUserId;
  final String avatarUrl;
  final String name;
  final String description;
  final String timeText;

  ChatModel({
    required this.id,
    required this.isAi,
    required this.aiId,
    required this.imUserId,
    required this.avatarUrl,
    required this.name,
    required this.description,
    required this.timeText,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      isAi: json['isAi'] ?? false,
      aiId: json['aiId'] ?? '',
      imUserId: json['imUserId'] ?? '',
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
      'aiId': aiId,
      'imUserId': imUserId,
      'avatarUrl': avatarUrl,
      'name': name,
      'description': description,
      'timeText': timeText,
    };
  }
}
