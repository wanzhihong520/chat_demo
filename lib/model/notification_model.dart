class NotificationListModel {
  final List<NotificationModel> list;
  final int unreadCount;

  NotificationListModel({required this.list, required this.unreadCount});

  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    final items = json['list'] as List? ?? [];
    return NotificationListModel(
      unreadCount: json['unreadCount'] ?? 0,
      list: items
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String content;
  final Map<String, dynamic> meta;
  final bool isRead;
  final String createdAt;
  final String timeText;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.meta,
    required this.isRead,
    required this.createdAt,
    required this.timeText,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      meta: meta is Map
          ? Map<String, dynamic>.from(meta)
          : <String, dynamic>{},
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      timeText: json['timeText'] ?? '',
    );
  }
}
