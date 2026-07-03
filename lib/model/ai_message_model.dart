class AiMessageModel {
  final String id;
  final String role;
  final String content;
  final String createdAt;

  AiMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isUser => role == 'user';

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class AiMessageListModel {
  final List<AiMessageModel> list;
  final bool hasMore;
  final int total;

  AiMessageListModel({
    required this.list,
    required this.hasMore,
    required this.total,
  });

  factory AiMessageListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return AiMessageListModel(
      list: items
          .map((e) => AiMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] ?? false,
      total: json['total'] ?? 0,
    );
  }
}
