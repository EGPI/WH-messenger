class ConversationListResponse {
  final List<ConversationSummaryModel> data;
  final ConversationMetaModel meta;

  const ConversationListResponse({
    required this.data,
    required this.meta,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];

    return ConversationListResponse(
      data: rawData
          .map(
            (item) => ConversationSummaryModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      meta: ConversationMetaModel.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ConversationSummaryModel {
  final int id;
  final String type;
  final String? title;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int? lastMessageSenderId;
  final int unreadCount;
  final String? myRole;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConversationSummaryModel({
    required this.id,
    required this.type,
    required this.title,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.lastMessageSenderId,
    required this.unreadCount,
    required this.myRole,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationSummaryModel.fromJson(Map<String, dynamic> json) {
    return ConversationSummaryModel(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String?,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: _parseDateTime(json['last_message_at']),
      lastMessageSenderId: json['last_message_sender_id'] as int?,
      unreadCount: json['unread_count'] as int? ?? 0,
      myRole: json['my_role'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }
}

class ConversationMetaModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const ConversationMetaModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory ConversationMetaModel.fromJson(Map<String, dynamic> json) {
    return ConversationMetaModel(
      currentPage: json['current_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is! String || value.isEmpty) return null;

  return DateTime.tryParse(value);
}