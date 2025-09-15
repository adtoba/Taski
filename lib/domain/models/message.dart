class ChatMessage {
  final String? sessionId;
  final String? id;
  final String? content;
  final String? type;
  final bool? isUser;
  final DateTime? createdAt;

  ChatMessage({this.sessionId, this.id, this.content, this.type, this.isUser, this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sessionId: json['sessionId'],
      id: json['id'],
      content: json['content'],
      type: json['type'],
      isUser: json['isUser'],
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'id': id,
      'content': content,
      'type': type,
      'isUser': isUser,
      'createdAt': createdAt,
    };
  }
}