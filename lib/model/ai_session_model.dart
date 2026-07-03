class AiSessionModel {
  final String sessionId;
  final String aiId;
  final String avatarUrl;
  final String name;
  final String description;
  final String timeText;

  AiSessionModel({
    required this.sessionId,
    required this.aiId,
    required this.avatarUrl,
    required this.name,
    required this.description,
    required this.timeText,
  });

  factory AiSessionModel.fromJson(Map<String, dynamic> json) {
    return AiSessionModel(
      sessionId: json['sessionId'] ?? '',
      aiId: json['aiId'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      timeText: json['timeText'] ?? '',
    );
  }
}

class AiSessionListModel {
  final List<AiSessionModel> list;

  AiSessionListModel({required this.list});

  factory AiSessionListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return AiSessionListModel(
      list: items
          .map((e) => AiSessionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
