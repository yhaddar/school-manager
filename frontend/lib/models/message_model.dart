class MessageModel {
  final int id;
  final String subject;
  final String message;
  final String type;
  final int senderId;
  final int? recipientId;
  final dynamic data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.type,
    required this.senderId,
    this.recipientId,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      subject: json['subject'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      senderId: json['sender_id'] as int,
      recipientId: json['recipient_id'] as int?,
      data: json['data'] as dynamic,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'type': type,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
